# frozen_string_literal: true

module Flatirons
  module Saas
    class Engine < ::Rails::Engine
      isolate_namespace Flatirons::Saas

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.factory_bot dir: 'spec/factories'
      end
      ActiveSupport.on_load(:active_record) do
        extend Flatirons::Saas::Concerns::SoftDeletable::Load
        extend Flatirons::Saas::Concerns::Productable::Load
      end
    end
  end
end
