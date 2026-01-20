# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include ExceptionHandler
    include ResponseHelper

    rescue_from StandardError, with: :handle_exception
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

    private

    def handle_exception(exception)
      Rails.logger.error("Exception: #{exception.class} - #{exception.message}")
      Rails.logger.error(exception.backtrace.join("\n"))

      render json: {
        error: 'Internal server error',
        message: exception.message
      }, status: :internal_server_error
    end

    def record_not_found(exception)
      render json: {
        error: 'Record not found',
        message: exception.message
      }, status: :not_found
    end

    def record_invalid(exception)
      render json: {
        error: 'Validation failed',
        message: exception.message,
        details: exception.record.errors.full_messages
      }, status: :unprocessable_content
    end
  end
end

