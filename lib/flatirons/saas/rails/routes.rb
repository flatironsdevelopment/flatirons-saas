# frozen_string_literal: true

module Flatirons
  module Saas
    module Rails
      module Subscription
        mattr_accessor :mappings
        @@mappings = {} # rubocop:disable Style/ClassVars
      end

      module Product
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
    # by calling +subscription_for+ with a +devise_for+, it automatically nests your subscriptions with the authenticated resource.
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use +subscriptable+,
    # After creating this inside your routes:
    #
    #   devise_for :users
    #   subscription_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #   # Subscription routes for authenticated resource (default)
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
      concern_name = 'subscriptable'
      method_prefix = 'subscription'
      module_class = Flatirons::Saas::Rails::Subscription

      resources.each do |resource|
        ref = extract_resource_ref resource, options, module_class, method_prefix
        ensure_concern! ref[:klass], concern_name

        routing_resource_scope(symbol: ref[:symbol], module_class: module_class) do
          with_exclusive_scope ref do
            resources 'subscriptions', controller: 'flatirons/saas/subscriptions', only: %i[index create update]
            resources 'payment_methods', controller: 'flatirons/saas/payment_methods', only: %i[index create]
          end
        end
      end
    end

    def products_for(*resources)
      options = resources.extract_options!
      resources.map!(&:to_sym)
      concern_name = 'productable'
      method_prefix = 'products'
      module_class = Flatirons::Saas::Rails::Product

      resources.each do |resource|
        ref = extract_resource_ref resource, options, module_class, method_prefix
        ensure_concern! ref[:productable_klass], concern_name

        routing_resource_scope(symbol: ref[:symbol], module_class: module_class) do
          with_exclusive_scope ref do
            resources 'products', controller: 'flatirons/saas/products', only: %i[index]
          end
        end
      end
    end

    private

    def routing_resource_scope(**args, &block) # :nodoc:
      symbol = args[:symbol]
      module_class = args[:module_class]
      constraint = lambda do |request|
        request.env['flatirons.saas.mapping'] = module_class.mappings[symbol]
        true
      end
      constraints(constraint, &block)
    end

    def with_exclusive_scope(ref) # :nodoc:
      new_path = ref[:path]
      new_as = ref[:name]
      current_scope = @scope.dup
      exclusive = { as: new_as, path: new_path, module: nil }
      @scope = @scope.new exclusive
      yield
    ensure
      @scope = current_scope
    end

    def extract_resource_ref(resource, options, module_class, method_prefix) # :nodoc:
      name = resource.to_s.singularize.to_s
      symbol = name.to_sym
      klass = (options[:class_name] || resource.to_s.classify).to_s.constantize
      path = (options[:path] || resource).to_s
      productable_klass = options[:productable_class_name]&.constantize || Flatirons::Saas::Product

      ensure_devise_for_resource! resource, symbol, klass, method_prefix

      module_class.mappings[symbol] =
        { symbol: symbol, name: name, path: path, klass: klass, resource: resource, productable_klass: productable_klass }
      module_class.mappings[symbol]
    end

    def ensure_devise_for_resource!(resource, symbol, klass, method_prefix) # :nodoc:
      raise 'Devise is not available, please include devise gem to get work.' unless Object.const_defined?('Devise')
      raise "Devise for :#{resource} not found, please check your #{method_prefix}_for/devise_for route configuration." unless Devise.mappings[symbol]

      klass_name = klass.name
      devise_mapping = Devise.mappings[symbol]
      devise_klass_name = devise_mapping.class_name
      unless devise_klass_name == klass_name # rubocop:disable Style/GuardClause
        raise "Devise resource type [#{devise_klass_name}] is not the same of #{method_prefix}_for [#{klass_name}],"\
        " check your #{method_prefix}_for/devise_for route configuration."
      end
    end

    def ensure_concern!(klass, concern_name) # :nodoc:
      raise "#{klass} does not respond to '#{concern_name}' method." unless klass.respond_to?("#{concern_name}?") && klass.send("#{concern_name}?")
    end
  end
end
