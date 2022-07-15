# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      #
      # Productable Concern
      #
      module Productable
        extend ActiveSupport::Concern

        def productable_options
          self.class.productable_options
        end

        module Load
          mattr_accessor :productable_options

          #
          # Productable?
          #
          # Check productable concern to a class that inherits from ActiveRecord::Base
          #
          # @return [void]
          #
          def productable?
            included_modules.include?(Flatirons::Saas::Concerns::Productable)
          end

          #
          # Productable
          #
          # Adds productable concern to a class that inherits from `ActiveRecord::Base`
          #
          # @param delete_product_on_destroy [Boolean]
          #
          # @return [void]
          #
          def productable(*opts)
            return if productable?

            @@productable_options = opts.extract_options! # rubocop:disable Style/ClassVars

            include Flatirons::Saas::Concerns::Stripe
            include Flatirons::Saas::Concerns::StripeProduct
            include Flatirons::Saas::Concerns::Productable
          end
        end
      end
    end
  end
end
