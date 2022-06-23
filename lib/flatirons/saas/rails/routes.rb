# frozen_string_literal: true

module Flatirons
  module Saas
    module Rails
      module Subscription
        mattr_accessor :mappings
        @@mappings = {} # rubocop:disable Style/ClassVars
      end
    end
  end
end

module ActionDispatch::Routing
  class Mapper
    def subscription_for(*resources)
      options = resources.extract_options!
      resources.map!(&:to_sym)
      resources.each do |resource|
        name = resource.to_s.singularize.to_s
        klass = (options[:class_name] || resource.to_s.classify).constantize
        ensure_subscriptable! klass
        symbol = name.to_sym
        resource_ref = { symbol: symbol, name: name, klass: klass, resource: resource }
        Flatirons::Saas::Rails::Subscription.mappings[symbol] = resource_ref
        subscription_scope symbol do
          with_subscription_exclusive_scope resource, name do
            resources 'subscriptions', controller: 'flatirons/saas/subscriptions', only: %i[index create update]
          end
        end
      end
    end

    def subscription_scope(symbol, &block)
      constraint = lambda do |request|
        Rails.logger.debug 'constraint registered'
        request.env['flatirons.saas.mapping'] = Flatirons::Saas::Rails::Subscription.mappings[symbol]
        true
      end
      constraints(constraint, &block)
    end

    def with_subscription_exclusive_scope(new_path, new_as) # :nodoc:
      current_scope = @scope.dup
      exclusive = { as: new_as, path: new_path, module: nil }
      @scope = @scope.new exclusive
      yield
    ensure
      @scope = current_scope
    end

    def ensure_subscriptable!(klass)
      raise "#{klass} does not respond to 'subscriptable' method." unless klass.respond_to?('subscriptable?') && klass.subscriptable?
    end
  end
end
