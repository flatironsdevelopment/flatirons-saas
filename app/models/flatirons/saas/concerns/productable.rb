# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      #
      # Productable Concern
      #
      module Productable
        extend ActiveSupport::Concern

        included do
          validates :name, presence: true
        end

        module Load
          def productable?
            included_modules.include?(Flatirons::Saas::Concerns::Productable)
          end

          def productable
            return if productable?

            include Flatirons::Saas::Concerns::Productable
          end
        end
      end
    end
  end
end
