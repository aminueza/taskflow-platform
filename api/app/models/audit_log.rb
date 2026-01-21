# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :resource, polymorphic: true, optional: true

  validates :action, presence: true
  validates :resource_type, presence: true
end
