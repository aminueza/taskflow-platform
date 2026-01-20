# frozen_string_literal: true

class UserMailerWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :mailers, backtrace: true

  def perform(user_id, mail_type)
    user = User.find(user_id)

    case mail_type
    when 'welcome'
      UserMailer.welcome_email(user).deliver_now
    when 'password_reset'
      UserMailer.password_reset_email(user).deliver_now
    else
      raise ArgumentError, "Unknown mail type: #{mail_type}"
    end

    Rails.logger.info(
      event: 'email_sent',
      user_id: user_id,
      mail_type: mail_type
    )
  rescue StandardError => e
    Rails.logger.error(
      event: 'email_failed',
      user_id: user_id,
      mail_type: mail_type,
      error: e.message
    )
    raise
  end
end
