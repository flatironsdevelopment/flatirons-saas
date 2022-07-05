# frozen_string_literal: true

FactoryBot.define do
  factory :product, class: 'Flatirons::Saas::Product' do
    name { Faker::Name.name }
  end
end
