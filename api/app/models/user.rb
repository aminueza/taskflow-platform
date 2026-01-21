# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :tasks, dependent: :destroy
  has_many :audit_logs, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :downcase_email

  scope :active, -> { where(deleted_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def active?
    deleted_at.nil?
  end

  def generate_token(expires_in: 24.hours)
    payload = {
      user_id: id,
      exp: expires_in.from_now.to_i
    }
    secret = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
    JWT.encode(payload, secret, 'HS256')
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
