require "generator_spec"
require "rails_helper"
require 'generators/productable/productable_generator.rb'

describe ProductableGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)
  arguments %w(SomeProduct)

  before(:all) do
    allow(Rails::VERSION::MAJOR) { 6 }
    allow(Rails::VERSION::MINOR) { 1 }
    prepare_destination
    run_generator
  end

  describe 'model exists' do
    it "#generate_migration" do
      assert_file "app/models/some_product.rb"
      run_generator
      migration_folder_contents = Dir.children('spec/generators/tmp/db/migrate').sort
      migration_file_name = migration_folder_contents.last

      expect(migration_folder_contents.size).to eq(2)
      assert migration_file_name.include?("add_productable_to_some_products")
      assert_file "db/migrate/#{migration_file_name}"
    end

  end

  describe 'Model does not exist' do
    before(:all) do
      prepare_destination
      run_generator
    end

    it "#generate_model" do
      assert_file "app/models/some_product.rb"
    end

    it "#generate_migration" do
      migration_folder_contents = Dir.children('spec/generators/tmp/db/migrate')
      migration_file_name = migration_folder_contents.first

      expect(migration_folder_contents.size).to eq(1)
      expect(migration_file_name.include?("some_products")).to eq(true)
      assert_file "db/migrate/#{migration_file_name}"
    end
  end
end


