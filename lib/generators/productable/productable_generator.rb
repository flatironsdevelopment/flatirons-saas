require 'rails/generators/active_record'

class ProductableGenerator < ActiveRecord::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path("templates", __dir__)

  def generate_migration
    if model_exists?
      migration_template "existing_productable_migration.rb", "db/migrate/add_productable_to_#{table_name}.rb", rails_version: rails_version
    else
      migration_template "productable_migration.rb", "db/migrate/create_#{table_name}.rb", rails_version: rails_version
    end
  end

  def generate_model
    invoke "active_record:model", [name], migration: false unless model_exists?
  end

  private

  def rails_version
    "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
  end

  def model_exists?
    File.exist?(File.join(destination_root, model_path))
  end

  def model_path
    @model_path ||= File.join("app", "models", "#{model_name}.rb")
  end

  def model_name
    name.underscore
  end
end
