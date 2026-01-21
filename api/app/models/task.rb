# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user, optional: true

  STATUSES = %w[pending in_progress completed].freeze

  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
end
