require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = true

  # Cache configuration - use Redis if available, otherwise memory store
  if ENV['REDIS_URL'].present?
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'],
      expires_in: 1.hour,
      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.warn "Redis cache error: #{exception.message}"
      }
    }
  else
    config.cache_store = :memory_store, { size: 64.megabytes }
  end

  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')
  config.log_tags = [:request_id]
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
