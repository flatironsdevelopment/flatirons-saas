# frozen_string_literal: true

FactoryBot.define do
  factory :subscription, class: 'Flatirons::Saas::Subscription' do
    status { 'active' }
    deleted_at { nil }
    stripe_subscription_id { Faker::Internet.uuid }
  end
end
