# frozen_string_literal: true

require 'rails_helper'
require 'generator_spec'

RSpec.describe Flatirons::Saas::Generators::SubscriptableGenerator, type: :generator do
  destination File.expand_path('../tmp', __dir__)
  arguments %w(test --test)

  before(:all) do
    prepare_destination
    run_generator
  end

  it 'creates a migration' do
    assert_migration 'db/migrate/create_tests.rb'
  end

  it 'creates a model' do
    assert_file 'app/models/test.rb'
  end
end
