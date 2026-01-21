# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health Check', type: :request do
  describe 'GET /health' do
    before do
      allow_any_instance_of(HealthController).to receive(:check_redis).and_return(true)
      allow_any_instance_of(HealthController).to receive(:check_sidekiq).and_return(1)
    end

    it 'returns healthy status' do
      get '/health'

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('healthy')
    end

    it 'includes timestamp' do
      get '/health'

      expect(json_response['timestamp']).to be_present
    end

    it 'includes database status' do
      get '/health'

      expect(json_response['checks']).to include('database')
    end

    it 'includes redis status' do
      get '/health'

      expect(json_response['checks']).to include('redis')
    end

    it 'includes sidekiq status' do
      get '/health'

      expect(json_response['checks']).to include('sidekiq')
    end

    context 'when database is down' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError)
        allow(Rails.logger).to receive(:error)
      end

      it 'returns unhealthy status' do
        get '/health'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('unhealthy')
        expect(json_response['checks']['database']).to eq('disconnected')
      end
    end

    context 'when redis is down' do
      before do
        allow_any_instance_of(HealthController).to receive(:check_redis).and_return(false)
      end

      it 'returns unhealthy status' do
        get '/health'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('unhealthy')
        expect(json_response['checks']['redis']).to eq('disconnected')
      end
    end

    context 'when sidekiq is down' do
      before do
        allow_any_instance_of(HealthController).to receive(:check_sidekiq).and_return(0)
      end

      it 'returns unhealthy status' do
        get '/health'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('unhealthy')
        expect(json_response['checks']['sidekiq']).to eq(0)
      end
    end
  end

  describe 'GET /health/ready' do
    before do
      allow_any_instance_of(HealthController).to receive(:check_redis).and_return(true)
    end

    it 'returns ready status when all services are up' do
      get '/health/ready'

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('ready')
    end

    it 'includes timestamp' do
      get '/health/ready'

      expect(json_response['timestamp']).to be_present
    end

    it 'includes database and redis checks' do
      get '/health/ready'

      expect(json_response['checks']).to include('database', 'redis')
    end

    context 'when database is down' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError)
        allow(Rails.logger).to receive(:error)
      end

      it 'returns not_ready status' do
        get '/health/ready'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('not_ready')
        expect(json_response['checks']['database']).to eq('disconnected')
      end
    end

    context 'when redis is down' do
      before do
        allow_any_instance_of(HealthController).to receive(:check_redis).and_return(false)
      end

      it 'returns not_ready status' do
        get '/health/ready'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('not_ready')
        expect(json_response['checks']['redis']).to eq('disconnected')
      end
    end
  end

  describe 'GET /health/live' do
    it 'returns alive status' do
      get '/health/live'

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('alive')
    end

    it 'includes timestamp' do
      get '/health/live'

      expect(json_response['timestamp']).to be_present
    end
  end

  private

  def json_response
    response.parsed_body
  end
end
