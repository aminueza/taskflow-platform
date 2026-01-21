# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Metrics', type: :request do
  describe 'GET /metrics' do
    before do
      create_list(:user, 5)
      create_list(:task, 10, status: 'pending')
      create_list(:task, 5, status: 'in_progress')
      create_list(:task, 15, status: 'completed')
    end

    it 'returns metrics in Prometheus format' do
      get '/metrics'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/plain')
    end

    it 'includes rails_info metrics' do
      get '/metrics'

      expect(response.body).to include('# HELP rails_info Application information')
      expect(response.body).to include('# TYPE rails_info gauge')
      expect(response.body).to include('rails_info')
    end

    context 'system metrics' do
      it 'includes memory metrics when available' do
        allow(File).to receive(:exist?).with('/proc/self/status').and_return(true)
        allow(File).to receive(:read).with('/proc/self/status').and_return("VmRSS: 1024 kB\n")

        get '/metrics'

        expect(response.body).to include('# HELP process_resident_memory_bytes')
        expect(response.body).to include('# TYPE process_resident_memory_bytes gauge')
        expect(response.body).to include('process_resident_memory_bytes')
      end

      it 'includes CPU metrics when available' do
        allow(File).to receive(:exist?).with('/proc/self/stat').and_return(true)
        allow(File).to receive(:read).with('/proc/self/stat').and_return(
          '1 (ruby) R 0 0 0 0 0 0 0 0 0 0 100 200 0 0 0 0 1 0 0 0 0 0 0 0 0 0'
        )

        get '/metrics'

        expect(response.body).to include('# HELP process_cpu_seconds_total')
        expect(response.body).to include('# TYPE process_cpu_seconds_total counter')
        expect(response.body).to include('process_cpu_seconds_total')
      end

      it 'includes thread count metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP process_threads')
        expect(response.body).to include('# TYPE process_threads gauge')
        expect(response.body).to include('process_threads')
      end

      it 'handles system metrics errors gracefully' do
        allow(File).to receive(:exist?).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error)

        expect { get '/metrics' }.not_to raise_error
        expect(response).to have_http_status(:ok)
      end
    end

    context 'database metrics' do
      it 'includes database_up metric when connection is successful' do
        get '/metrics'

        expect(response.body).to include('# HELP database_up')
        expect(response.body).to include('# TYPE database_up gauge')
        expect(response.body).to include('database_up 1')
      end

      it 'includes database pool metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP database_pool_size')
        expect(response.body).to include('# TYPE database_pool_size gauge')
        expect(response.body).to include('database_pool_size')
        expect(response.body).to include('# HELP database_pool_connections')
        expect(response.body).to include('database_pool_connections')
      end

      it 'reports database down when connection fails' do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError)

        get '/metrics'

        expect(response.body).to include('database_up 0')
      end
    end

    context 'Redis metrics' do
      it 'reports redis_up when Redis is available' do
        redis_double = instance_double(Redis)
        allow(Redis).to receive(:new).and_return(redis_double)
        allow(redis_double).to receive(:ping).and_return('PONG')
        allow(redis_double).to receive(:info).and_return(
          'connected_clients' => 10,
          'used_memory' => 1024000
        )

        get '/metrics'

        expect(response.body).to include('# HELP redis_up')
        expect(response.body).to include('redis_up 1')
        expect(response.body).to include('# HELP redis_connected_clients')
        expect(response.body).to include('redis_connected_clients 10')
        expect(response.body).to include('# HELP redis_used_memory_bytes')
        expect(response.body).to include('redis_used_memory_bytes 1024000')
      end

      it 'reports redis down when Redis is unavailable' do
        allow(Redis).to receive(:new).and_raise(StandardError)

        get '/metrics'

        expect(response.body).to include('redis_up 0')
      end
    end

    context 'Sidekiq metrics' do
      it 'includes Sidekiq metrics when available' do
        stats_double = instance_double(Sidekiq::Stats, processed: 100, failed: 5, enqueued: 10)
        process_set_double = instance_double(Sidekiq::ProcessSet, size: 2)

        allow(Sidekiq::Stats).to receive(:new).and_return(stats_double)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set_double)

        get '/metrics'

        expect(response.body).to include('# HELP sidekiq_processed_total')
        expect(response.body).to include('sidekiq_processed_total 100')
        expect(response.body).to include('# HELP sidekiq_failed_total')
        expect(response.body).to include('sidekiq_failed_total 5')
        expect(response.body).to include('# HELP sidekiq_enqueued')
        expect(response.body).to include('sidekiq_enqueued 10')
        expect(response.body).to include('# HELP sidekiq_processes')
        expect(response.body).to include('sidekiq_processes 2')
      end

      it 'handles Sidekiq errors gracefully' do
        allow(Sidekiq::Stats).to receive(:new).and_raise(StandardError.new('Sidekiq not available'))
        allow(Rails.logger).to receive(:error)

        expect { get '/metrics' }.not_to raise_error
        expect(response).to have_http_status(:ok)
      end
    end

    context 'HTTP metrics' do
      it 'includes HTTP request metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP http_requests_total')
        expect(response.body).to include('# TYPE http_requests_total counter')
        expect(response.body).to include('http_requests_total{method=')
        expect(response.body).to include('# HELP http_request_duration_seconds')
        expect(response.body).to include('http_request_duration_seconds{quantile=')
      end

      it 'includes multiple HTTP status codes' do
        get '/metrics'

        expect(response.body).to include('status="200"')
        expect(response.body).to include('status="201"')
        expect(response.body).to include('status="404"')
        expect(response.body).to include('status="422"')
      end
    end

    context 'application metrics' do
      it 'includes user count metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP app_users_total')
        expect(response.body).to include('# TYPE app_users_total gauge')
        expect(response.body).to include('app_users_total 5')
      end

      it 'includes task count metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP app_tasks_total')
        expect(response.body).to include('app_tasks_total 30')
      end

      it 'includes tasks grouped by status' do
        get '/metrics'

        expect(response.body).to include('# HELP app_tasks_by_status')
        expect(response.body).to include('app_tasks_by_status{status="pending"} 10')
        expect(response.body).to include('app_tasks_by_status{status="in_progress"} 5')
        expect(response.body).to include('app_tasks_by_status{status="completed"} 15')
      end

      it 'handles application metrics errors gracefully' do
        allow(User).to receive(:count).and_raise(StandardError)
        allow(Rails.logger).to receive(:error)

        expect { get '/metrics' }.not_to raise_error
        expect(response).to have_http_status(:ok)
      end
    end

    context 'SLO/SLI metrics' do
      it 'includes availability metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP sli_availability_percent')
        expect(response.body).to include('# TYPE sli_availability_percent gauge')
        expect(response.body).to include('sli_availability_percent')
      end

      it 'includes error rate metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP sli_error_rate_percent')
        expect(response.body).to include('sli_error_rate_percent')
      end

      it 'includes latency SLI metrics' do
        get '/metrics'

        expect(response.body).to include('# HELP sli_latency_fast_percent')
        expect(response.body).to include('sli_latency_fast_percent')
      end

      it 'handles SLI metrics errors gracefully' do
        allow_any_instance_of(MetricsController).to receive(:rand).and_raise(StandardError)
        allow(Rails.logger).to receive(:error)

        expect { get '/metrics' }.not_to raise_error
      end
    end
  end
end
