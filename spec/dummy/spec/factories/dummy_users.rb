# frozen_string_literal: true

FactoryBot.define do
  factory :dummy_user do
    name { Faker.name }
  end
end
