# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      module StripeCustomer
        extend ActiveSupport::Concern

        included do
          before_commit :create_stripe_customer, on: :create
          after_destroy :destroy_stripe_customer
        end

        def self.included(klazz)
          klazz.extend Callbacks
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
        # Create the stripe customer before commit
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

        #
        # Destroy the stripe customer after destroy
        #
        # @return [Hash]
        #
        def destroy_stripe_customer
          raise 'stripe_customer_id attribute not found.' unless has_attribute? :stripe_customer_id

          delete_customer_on_destroy = subscriptable_options[:delete_customer_on_destroy]
          stripe_customer_id = self[:stripe_customer_id]

          return true if stripe_customer_id.nil? || delete_customer_on_destroy != true

          result = transaction do
            run_callbacks :stripe_customer_deletion do
              stripe_service.destroy_customer stripe_customer_id
            end
          end

          result ? self : false
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

            klazz.define_callbacks :stripe_customer_deletion
            klazz.define_singleton_method('before_stripe_customer_deletion') do |*args, &block|
              set_callback(:stripe_customer_deletion, :before, *args, &block)
            end
            klazz.define_singleton_method('around_stripe_customer_deletion') do |*args, &block|
              set_callback(:stripe_customer_deletion, :around, *args, &block)
            end
            klazz.define_singleton_method('after_stripe_customer_deletion') do |*args, &block|
              set_callback(:stripe_customer_deletion, :after, *args, &block)
            end
          end
        end
      end
    end
  end
end
