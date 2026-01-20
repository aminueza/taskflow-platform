require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module AzureWebappChallenge
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.1
    config.load_defaults 7.1

    # API-only application
    config.api_only = true

    # Middleware for API
    config.middleware.use Rack::Cors
    config.middleware.use Rack::Attack

    # Active Job adapter
    config.active_job.queue_adapter = :sidekiq

    # Time zone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Localization
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en]

    # Eager loading paths
    config.eager_load_paths << Rails.root.join("lib")

    # Cache store - configured in environment files
    # Development uses memory store, production uses Redis

    # Logging
    config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym
    config.log_tags = [:request_id, :remote_ip]

    # JSON logging in production
    if Rails.env.production?
      config.log_formatter = ::Logger::Formatter.new
      config.logger = ActiveSupport::Logger.new(STDOUT)
      config.logger.formatter = config.log_formatter
    end

    # Health check route configured in routes.rb

    # Use default Rails error handling
  end
end
