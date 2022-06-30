# frozen_string_literal: true

require 'generators/active_record_base_generator'

class SubscriptableGenerator < ActiveRecordBase
  source_root File.expand_path('templates', __dir__)
  def template_suffix
    'subscriptable'
  end
end
