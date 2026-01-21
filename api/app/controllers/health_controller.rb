# frozen_string_literal: true

class HealthController < ApplicationController
  def index
    db_status = check_database
    redis_status = check_redis
    sidekiq_status = check_sidekiq

    status = db_status && redis_status && sidekiq_status.positive? ? 'healthy' : 'unhealthy'

    render json: {
      status: status,
      timestamp: Time.current.iso8601,
      checks: {
        database: db_status ? 'connected' : 'disconnected',
        redis: redis_status ? 'connected' : 'disconnected',
        sidekiq: sidekiq_status
      }
    }
  end

  def live
    render json: { status: 'alive', timestamp: Time.current.iso8601 }
  end

  def ready
    db_status = check_database
    redis_status = check_redis

    status = db_status && redis_status ? 'ready' : 'not_ready'

    render json: {
      status: status,
      timestamp: Time.current.iso8601,
      checks: {
        database: db_status ? 'connected' : 'disconnected',
        redis: redis_status ? 'connected' : 'disconnected'
      }
    }
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue StandardError => e
    Rails.logger.error("Database health check failed: #{e.message}")
    false
  end

  def check_redis
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    redis.ping == 'PONG'
  rescue StandardError => e
    Rails.logger.error("Redis health check failed: #{e.message}")
    false
  end

  def check_sidekiq
    Sidekiq::ProcessSet.new.size
  rescue StandardError
    0
  end
end
