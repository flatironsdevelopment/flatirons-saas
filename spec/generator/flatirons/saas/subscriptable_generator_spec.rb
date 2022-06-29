# frozen_string_literal: true

require 'rails_helper'
require 'generator_spec'

module Flatirons::Saas::Generators
  RSpec.describe SubscriptableGenerator, type: :generator do
    destination File.expand_path('../../../../tmp', __dir__)
    arguments %w(user_test)

    before(:all) do
      allow(Rails::VERSION::MAJOR) { 6 }
      allow(Rails::VERSION::MINOR) { 1 }

      prepare_destination
      run_generator
    end

    describe 'model exists' do
      it 'creates a migration' do
        assert_file 'app/models/user_test.rb'
        run_generator

        migration_folder_contents = Dir.children("#{test_case.destination_root}/db/migrate").sort
        migration_file_name = migration_folder_contents.last

        expect(migration_folder_contents.size).to eq(2)
        assert migration_file_name.include?('add_subscriptable_to_user_tests')
        assert_file "db/migrate/#{migration_file_name}"
      end
    end

    describe 'Model does not exist' do
      it 'creates a migration' do
        assert_migration 'db/migrate/create_user_tests.rb'
      end

      it 'creates a model' do
        assert_file 'app/models/user_test.rb'
      end
    end
  end
end
