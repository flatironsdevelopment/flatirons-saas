# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      module StripeProduct
        extend ActiveSupport::Concern

        included do
          before_commit :create_stripe_product, on: :create
          after_destroy :destroy_stripe_product
        end

        def self.included(klazz)
          klazz.extend Callbacks
        end

        #
        # Define stripe product name
        #
        # @return [String]
        #
        def stripe_product_name
          send(:name)
        end

        #
        # Define stripe product extra attributes
        #
        # @return [Hash]
        #
        def stripe_product_attrs
          {}
        end

        #
        # Create the stripe product before commit
        #
        # @return [Hash]
        #
        def create_stripe_product
          assert_stripe_product_id_attribute!

          stripe_product_id = self[:stripe_product_id]

          return true unless stripe_product_id.nil?

          result = transaction do
            run_callbacks :stripe_product_creation do
              product = stripe_service.create_product stripe_product_name, stripe_product_attrs
              update_column(:stripe_product_id, product.id)  # rubocop:disable Rails/SkipsModelValidations
            end
          end

          result ? self : false
        end

        #
        # Destroy the stripe product after destroy
        #
        # @return [Hash]
        #
        def destroy_stripe_product
          assert_stripe_product_id_attribute!

          delete_product_on_destroy = productable_options[:delete_product_on_destroy]
          stripe_product_id = self[:stripe_product_id]

          return true if stripe_product_id.nil? || delete_product_on_destroy != true

          result = transaction do
            run_callbacks :stripe_product_deletion do
              stripe_service.destroy_product stripe_product_id
            end
          end

          result ? self : false
        end

        module Callbacks
          def self.extended(klazz)
            klazz.define_callbacks :stripe_product_creation
            klazz.define_singleton_method('before_stripe_product_creation') do |*args, &block|
              set_callback(:stripe_product_creation, :before, *args, &block)
            end
            klazz.define_singleton_method('around_stripe_product_creation') do |*args, &block|
              set_callback(:stripe_product_creation, :around, *args, &block)
            end
            klazz.define_singleton_method('after_stripe_product_creation') do |*args, &block|
              set_callback(:stripe_product_creation, :after, *args, &block)
            end

            klazz.define_callbacks :stripe_product_deletion
            klazz.define_singleton_method('before_stripe_product_deletion') do |*args, &block|
              set_callback(:stripe_product_deletion, :before, *args, &block)
            end
            klazz.define_singleton_method('around_stripe_product_deletion') do |*args, &block|
              set_callback(:stripe_product_deletion, :around, *args, &block)
            end
            klazz.define_singleton_method('after_stripe_product_deletion') do |*args, &block|
              set_callback(:stripe_product_deletion, :after, *args, &block)
            end
          end
        end

        private

        def assert_stripe_product_id_attribute!
          raise 'stripe_product_id attribute not found.' unless has_attribute? :stripe_product_id
        end
      end
    end
  end
end
