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
    # Includes subscription_for method for routes. This method is responsible to
    # generate all needed routes for subscription.
    #
    # ==== Devise integration
    #
    # +subscription_for+ is build to play with devise. For example,
    # by calling +subscription_for+ with a devise_for, it automatically nests your subscriptions with the authenticated resource
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use subscriptable,
    # After creating this inside your routes:
    #
    #   devise_for :users
    #   subscription_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Subscription routes for authenticated resource (default)
    #   user_subscriptions GET    /users/subscriptions             {controller:"flatirons/saas/subscriptions", action:"index"}
    #   user_subscriptions GET    /users/subscriptions/:id         {controller:"flatirons/saas/subscriptions", action:"show"}
    #   user_subscriptions POST   /users/subscriptions             {controller:"flatirons/saas/subscriptions", action:"create"}
    #   user_subscriptions PUT    /users/subscriptions/:id         {controller:"flatirons/saas/subscriptions", action:"update"}
    #
    # ==== Options
    #
    # You can configure your routes with some options:
    #
    #  * class_name: set up a different class to be looked up by subscription, if it cannot be
    #    properly found by the route name.
    #
    #      subscription_for :users, class_name: 'Account'
    #
    #  * path: allows you to set up path name that will be used, as rails routes does.
    #    The following route configuration would set up your route as /accounts instead of /users:
    #
    #      subscription_for :users, path: 'accounts'
    #
    def subscription_for(*resources)
      options = resources.extract_options!
      resources.map!(&:to_sym)

      resources.each do |resource|
        ref = extract_resource_ref resource, options
        subscription_scope ref[:symbol] do
          with_subscription_exclusive_scope ref do
            resources 'subscriptions', controller: 'flatirons/saas/subscriptions', only: %i[index create update]
          end
        end
      end
    end

    def subscription_scope(symbol, &block) # :nodoc:
      constraint = lambda do |request|
        request.env['flatirons.saas.mapping'] = Flatirons::Saas::Rails::Subscription.mappings[symbol]
        true
      end
      constraints(constraint, &block)
    end

    def with_subscription_exclusive_scope(ref) # :nodoc:
      new_path = ref[:path]
      new_as = ref[:name]
      current_scope = @scope.dup
      exclusive = { as: new_as, path: new_path, module: nil }
      @scope = @scope.new exclusive
      yield
    ensure
      @scope = current_scope
    end

    def extract_resource_ref(resource, options) # :nodoc:
      name = resource.to_s.singularize.to_s
      symbol = name.to_sym
      klass = (options[:class_name] || resource.to_s.classify).to_s.constantize
      path = (options[:path] || resource).to_s

      ensure_devise! resource, symbol, klass
      ensure_subscriptable! klass

      Flatirons::Saas::Rails::Subscription.mappings[symbol] = { symbol: symbol, name: name, path: path, klass: klass, resource: resource }
      Flatirons::Saas::Rails::Subscription.mappings[symbol]
    end

    def ensure_devise!(resource, symbol, klass) # :nodoc:
      raise 'Devise is not available, please include devise gem to get work.' unless Object.const_defined?('Devise')
      raise "Devise for :#{resource} not found, please check your subscription_for/devise_for route configuration." unless Devise.mappings[symbol]

      klass_name = klass.name
      devise_mapping = Devise.mappings[symbol]
      devise_klass_name = devise_mapping.class_name

      unless devise_klass_name == klass_name # rubocop:disable Style/GuardClause
        raise "Devise resource type [#{devise_klass_name}] is not the same of subscription_for [#{klass_name}],"\
        ' check your subscription_for/devise_for route configuration.'
      end
    end

    def ensure_subscriptable!(klass) # :nodoc:
      raise "#{klass} does not respond to 'subscriptable' method." unless klass.respond_to?('subscriptable?') && klass.subscriptable?
    end
  end
end
