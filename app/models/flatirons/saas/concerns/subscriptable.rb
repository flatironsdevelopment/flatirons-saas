# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      #
      # Subscriptable Concern
      #
      module Subscriptable
        extend ActiveSupport::Concern

        included do
          has_many :subscriptions, class_name: 'Flatirons::Saas::Subscription', as: :subscriptable, dependent: :destroy
        end

        def self.included(klazz)
          klazz.extend Callbacks
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
            # TODO
          end
        end
      end
    end
  end
end
