# frozen_string_literal: true

module Flatirons::Saas::Services
  class StripeService
    def create_customer(name, extra_fields = {})
      Stripe::Customer.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_customer(customer_id)
      Stripe::Customer.delete customer_id, {}, stripe_opts
    end

    def create_product(name, extra_fields = {})
      Stripe::Product.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_product(product_id)
      Stripe::Product.delete product_id, {}, stripe_opts
    end

    private

    def stripe_opts
      raise 'Stripe API key not configured' if Flatirons::Saas.stripe_api_key.nil?

      { api_key: Flatirons::Saas.stripe_api_key }
    end
  end
end
