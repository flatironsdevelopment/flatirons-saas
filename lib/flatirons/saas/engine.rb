# frozen_string_literal: true

require 'money-rails'
require 'devise'
require 'rswag'
require 'stripe'
require 'devise/orm/active_record'
require 'flatirons/saas/rails/routes'
require 'flatirons/saas/services/stripe_service'
require 'jbuilder'

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

      ActiveSupport.on_load(:active_record) do
        extend Flatirons::Saas::Concerns::SoftDeletable::Load
        extend Flatirons::Saas::Concerns::Productable::Load
        extend Flatirons::Saas::Concerns::Subscriptable::Load
      end
    end
  end
end
