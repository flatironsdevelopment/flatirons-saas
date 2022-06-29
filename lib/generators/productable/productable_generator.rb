# frozen_string_literal: true

require 'generators/active_record_base_generator'

class ProductableGenerator < ActiveRecordBase
  source_root File.expand_path('templates', __dir__)
  def migration_name
    'productable'
  end
end
