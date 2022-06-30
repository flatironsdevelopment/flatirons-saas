# frozen_string_literal: true

module Flatirons::Saas
  class StripeService
    def create_customer(name, extra_fields = {})
      Stripe::Customer.create(extra_fields.merge({ name: name }))
    end
  end
end
