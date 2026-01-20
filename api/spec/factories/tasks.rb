# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :user
    sequence(:title) { |n| "Task #{n}" }
    description { Faker::Lorem.paragraph }
    status { 'pending' }

    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
    end

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :with_due_date do
      due_date { 1.week.from_now }
    end

    trait :overdue do
      due_date { 1.day.ago }
      status { 'pending' }
    end
  end
end

