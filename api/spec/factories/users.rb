# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { 'SecurePassword123!' }
    password_confirmation { 'SecurePassword123!' }
    deleted_at { nil }

    trait :deleted do
      deleted_at { Time.current }
    end

    trait :with_tasks do
      after(:create) do |user|
        create_list(:task, 3, user: user)
      end
    end
  end
end
