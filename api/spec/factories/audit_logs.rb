# frozen_string_literal: true

FactoryBot.define do
  factory :audit_log do
    association :user
    action { 'create' }
    resource_type { 'Task' }
    resource_id { 1 }
    metadata { { 'changes' => { 'status' => %w[pending completed] } } }

    trait :create_action do
      action { 'create' }
    end

    trait :update_action do
      action { 'update' }
    end

    trait :delete_action do
      action { 'delete' }
    end
  end
end
