# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy
    after_commit :log_change, on: [:create, :update, :destroy]
  end

  private

  def log_change
    action = case transaction_state
             when :create then 'created'
             when :update then 'updated'
             when :destroy then 'destroyed'
             end

    AuditLog.create!(
      auditable: self,
      action: action,
      changes: saved_changes,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent,
      user_id: Current.user&.id
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
