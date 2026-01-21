# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def handle_standard_error(exception)
    log_exception(exception)

    # Don't expose internal errors in production
    if Rails.env.production?
      render_error('An unexpected error occurred', status: :internal_server_error)
    else
      render_error(
        exception.message,
        errors: [{ backtrace: exception.backtrace.take(10) }],
        status: :internal_server_error
      )
    end

    # Send to Application Insights
    track_exception(exception) if defined?(ApplicationInsights)
  end

  def handle_not_found(exception)
    log_exception(exception, level: :warn)
    render_not_found(exception.message)
  end

  def handle_invalid_record(exception)
    log_exception(exception, level: :warn)
    render_unprocessable_entity(
      'Validation failed',
      errors: exception.record.errors.full_messages
    )
  end

  def handle_parameter_missing(exception)
    log_exception(exception, level: :warn)
    render_bad_request(exception.message)
  end

  def log_exception(exception, level: :error)
    Rails.logger.send(
      level,
      event: 'exception',
      exception_class: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace.take(5),
      request_id: @request_id,
      user_id: @current_user_id,
      path: request.fullpath,
      method: request.method
    )
  end

  def track_exception(exception)
    return if ENV['APPINSIGHTS_INSTRUMENTATIONKEY'].blank?

    client = ApplicationInsights::TelemetryClient.new(
      ENV.fetch('APPINSIGHTS_INSTRUMENTATIONKEY', nil)
    )

    client.track_exception(
      exception,
      properties: {
        request_id: @request_id,
        user_id: @current_user_id,
        path: request.fullpath,
        method: request.method
      }
    )

    client.flush
  end
end
