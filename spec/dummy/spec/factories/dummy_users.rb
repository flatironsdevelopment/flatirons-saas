# frozen_string_literal: true

FactoryBot.define do
  factory :dummy_user do
    email { Faker.email }
    password { Faker.password }
  end
end
