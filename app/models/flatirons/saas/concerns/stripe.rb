# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      module Stripe
        extend ActiveSupport::Concern

        #
        # Get StripeService instance
        #
        # @return [Flatirons::Saas::Services::StripeService]
        #
        def stripe_service
          @stripe_service ||= Flatirons::Saas::Services::StripeService.new
        end
      end
    end
  end
end
