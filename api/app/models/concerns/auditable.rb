# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :resource, dependent: :destroy
    after_commit :log_change, on: %i[create update destroy]
  end

  private

  def log_change
    action = case transaction_state
             when :create then 'created'
             when :update then 'updated'
             when :destroy then 'destroyed'
             end

    current = defined?(Current) ? Current : nil

    AuditLog.create!(
      resource: self,
      action: action,
      metadata: saved_changes,
      ip_address: current&.ip_address,
      user_agent: current&.user_agent,
      user_id: current&.user&.id
    )
  rescue StandardError => e
    Rails.logger.error(
      event: 'audit_log_failed',
      error: e.message,
      auditable_type: self.class.name,
      auditable_id: id
    )
  end

  def transaction_state
    if destroyed?
      :destroy
    elsif previously_new_record?
      :create
    else
      :update
    end
  end
end
