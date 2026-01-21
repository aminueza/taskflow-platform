require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # Cache configuration - using memory store for local development
  # For production, use: config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
  config.cache_store = :memory_store, { size: 67_108_864 } # 64 MB in bytes
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{2.days.to_i}"
  }

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Logging
  config.log_level = :debug
  config.log_tags = [:request_id]

  # Allow requests from Docker service names and localhost variations
  config.hosts << 'web'
  config.hosts << 'web:3000'
  config.hosts << 'localhost'
  config.hosts << '127.0.0.1'
  config.hosts << '.localhost'
end
