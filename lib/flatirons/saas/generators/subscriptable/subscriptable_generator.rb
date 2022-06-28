# frozen_string_literal: true

require 'flatirons/saas/generators/base_active_record_generator'

module Flatirons
  module Saas
    module Generators
      class SubscriptableGenerator < Flatirons::Saas::Generators::ActiveRecord::Base
        source_root File.expand_path('templates', __dir__)
        migration_name 'subscriptable'
      end
    end
  end
end
