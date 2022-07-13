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
        end

        def subscriptable_options
          self.class.subscriptable_options
        end

        module Load
          mattr_accessor :subscriptable_options

          def subscriptable?
            included_modules.include?(Flatirons::Saas::Concerns::Subscriptable)
          end

          #
          # subscriptable
          #
          # @param delete_customer_on_destroy [Boolean]
          #
          def subscriptable(*opts)
            return if subscriptable?

            @@subscriptable_options = opts.extract_options! # rubocop:disable Style/ClassVars

            include Flatirons::Saas::Concerns::Stripe
            include Flatirons::Saas::Concerns::StripeCustomer
            include Flatirons::Saas::Concerns::Subscriptable
          end
        end
      end
    end
  end
end
