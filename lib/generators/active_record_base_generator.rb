# frozen_string_literal: true

require 'rails/generators/active_record'

class ActiveRecordBase < ::ActiveRecord::Generators::Base
  include ::Rails::Generators::Migration

  def migration_name
    raise 'You need to implement this method'
  end

  def generate_migration
    if model_exists?
      migration_template "existing_#{migration_name}_migration.erb", "db/migrate/add_#{migration_name}_to_#{table_name}.rb",
                         rails_version: rails_version
    else
      migration_template "#{migration_name}_migration.erb", "db/migrate/create_#{table_name}.rb", rails_version: rails_version
    end
  end

  def generate_model
    invoke 'active_record:model', [name], migration: false unless model_exists?
  end

  def rails_version
    "#{::Rails::VERSION::MAJOR}.#{::Rails::VERSION::MINOR}"
  end

  def model_exists?
    File.exist?(File.join(destination_root, model_path))
  end

  def model_path
    @model_path ||= File.join('app', 'models', "#{model_name}.rb")
  end

  def model_name
    name.underscore
  end
end
