require "generator_spec"
require "rails_helper"
require 'generators/productable/productable_generator.rb'

describe ProductableGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)
  arguments %w(SomeModel)

  before(:all) do
    allow(Rails::VERSION::MAJOR) { 6 }
    allow(Rails::VERSION::MINOR) { 1 }
    prepare_destination
    run_generator
  end

  describe 'Model exists' do
  end

  describe 'Model does not exist' do
    it "#generate_model" do
      assert_file "app/models/some_model.rb"
    end

    it "#generate_migration" do
      migration_folder_contents = Dir.children('spec/generators/tmp/db/migrate')
      migration_file_name = migration_folder_contents.first

      assert migration_folder_contents.size, 1
      assert migration_file_name.include?("some_models")
      assert_file "db/migrate/#{migration_file_name}"
    end
  end
end


