# frozen_string_literal: true

module ResponseHelper
  extend ActiveSupport::Concern

  def render_success(data, message: nil, status: :ok, meta: {})
    response = {
      success: true,
      data: data,
      meta: meta.merge(
        request_id: @request_id,
        timestamp: Time.current.iso8601
      )
    }

    response[:message] = message if message.present?

    render json: response, status: status
  end

  def render_created(data, message: 'Resource created successfully')
    render_success(data, message: message, status: :created)
  end

  def render_error(message, errors: [], status: :internal_server_error)
    render json: {
      success: false,
      error: message,
      errors: errors,
      meta: {
        request_id: @request_id,
        timestamp: Time.current.iso8601
      }
    }, status: status
  end

  def render_bad_request(message, errors: [])
    render_error(message, errors: errors, status: :bad_request)
  end

  def render_unauthorized(message)
    render_error(message, status: :unauthorized)
  end

  def render_forbidden(message = 'Access denied')
    render_error(message, status: :forbidden)
  end

  def render_not_found(message = 'Resource not found')
    render_error(message, status: :not_found)
  end

  def render_unprocessable_entity(message, errors: [])
    render_error(message, errors: errors, status: :unprocessable_entity)
  end

  def render_conflict(message)
    render_error(message, status: :conflict)
  end
end
