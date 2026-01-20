# frozen_string_literal: true

class UserRegistrationService
  class RegistrationError < StandardError; end

  def initialize(params)
    @params = params
    @errors = []
  end

  def call
    ActiveRecord::Base.transaction do
      validate_params!
      create_user
      send_welcome_email
      track_registration
      log_success

      @user
    end
  rescue StandardError => e
    log_failure(e)
    raise RegistrationError, "Registration failed: #{e.message}"
  end

  private

  def validate_params!
    required_fields = [:email, :username, :password]
    missing_fields = required_fields - @params.keys

    if missing_fields.any?
      raise RegistrationError, "Missing required fields: #{missing_fields.join(', ')}"
    end
  end

  def create_user
    @user = User.create!(
      email: @params[:email],
      username: @params[:username],
      password: @params[:password],
      password_confirmation: @params[:password_confirmation]
    )
  end

  def send_welcome_email
    UserMailerWorker.perform_async(@user.id, 'welcome')
  end

  def track_registration
    # Track in Application Insights
    if ENV['APPINSIGHTS_INSTRUMENTATIONKEY'].present?
      client = ApplicationInsights::TelemetryClient.new(
        ENV['APPINSIGHTS_INSTRUMENTATIONKEY']
      )

      client.track_event(
        'user_registered',
        properties: {
          user_id: @user.id,
          email: @user.email,
          timestamp: Time.current.iso8601
        }
      )

      client.flush
    end
  end

  def log_success
    Rails.logger.info(
      event: 'user_registration_success',
      user_id: @user.id,
      email: @user.email
    )
  end

  def log_failure(exception)
    Rails.logger.error(
      event: 'user_registration_failed',
      error: exception.message,
      params: @params.except(:password, :password_confirmation)
    )
  end
end
