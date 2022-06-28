# frozen_string_literal: true

require 'money-rails'
require 'devise'
require 'rswag'
require 'rails/generators'
require 'rails/generators/active_record'
require 'devise/orm/active_record'
require 'flatirons/saas/rails/routes'
require 'flatirons/saas/generators/base_active_record_generator'

module Flatirons
  module Saas
    class Engine < ::Rails::Engine
      isolate_namespace Flatirons::Saas

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.factory_bot dir: 'spec/factories'
        g.assets false
        g.helper false
      end

      config.app_generators do
        require_relative 'generators/subscriptable/subscriptable_generator'
      end

      ActiveSupport.on_load(:active_record) do
        extend Flatirons::Saas::Concerns::SoftDeletable::Load
        extend Flatirons::Saas::Concerns::Productable::Load
        extend Flatirons::Saas::Concerns::Subscriptable::Load
      end
    end
  end
end
