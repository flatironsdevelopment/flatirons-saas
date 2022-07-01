# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      # Subscriptable takes care of the relationship between any active record model and the subscriptions.
      #
      # ==Options
      #
      # TODO...
      #
      # == Examples
      #
      #   # get all subscriptions
      #   User.find(1).subscriptions
      #
      module Subscriptable
        extend ActiveSupport::Concern

        included do
          has_many :subscriptions, class_name: 'Flatirons::Saas::Subscription', as: :subscriptable, dependent: :destroy
          after_commit :create_stripe_customer
        end

        def self.included(klazz)
          klazz.extend Callbacks
        end

        #
        # Get StripeService instance
        #
        # @return [Flatirons::Saas::Services::StripeService]
        #
        def stripe_service
          @stripe_service ||= Services::StripeService.new
        end

        #
        # Define stripe customer name
        #
        # @return [String]
        #
        def stripe_customer_name
          id = send(@primary_key)
          "#{self.class.table_name}_#{id}"
        end

        #
        # Define stripe customer extra attributes
        #
        # @return [Hash]
        #
        def stripe_customer_attrs
          {}
        end

        #
        # Create the stripe customer after save
        #
        # @return [Hash]
        #
        def create_stripe_customer
          raise 'stripe_customer_id attribute not found.' unless has_attribute? :stripe_customer_id

          stripe_customer_id = self[:stripe_customer_id]

          return true unless stripe_customer_id.nil?

          result = transaction do
            run_callbacks :stripe_customer_creation do
              customer = stripe_service.create_customer stripe_customer_name, stripe_customer_attrs
              update_column(:stripe_customer_id, customer.id)  # rubocop:disable Rails/SkipsModelValidations
            end
          end

          result ? self : false
        end

        module Load
          def subscriptable?
            included_modules.include?(Flatirons::Saas::Concerns::Subscriptable)
          end

          def subscriptable
            return if subscriptable?

            include Flatirons::Saas::Concerns::Subscriptable
          end
        end

        module Callbacks
          def self.extended(klazz)
            klazz.define_callbacks :stripe_customer_creation
            klazz.define_singleton_method('before_stripe_customer_creation') do |*args, &block|
              set_callback(:stripe_customer_creation, :before, *args, &block)
            end
            klazz.define_singleton_method('around_stripe_customer_creation') do |*args, &block|
              set_callback(:stripe_customer_creation, :around, *args, &block)
            end
            klazz.define_singleton_method('after_stripe_customer_creation') do |*args, &block|
              set_callback(:stripe_customer_creation, :after, *args, &block)
            end
          end
        end
      end
    end
  end
end
