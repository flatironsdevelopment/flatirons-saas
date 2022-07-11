# frozen_string_literal: true

module Flatirons::Saas::Services
  class StripeService
    def create_customer(name, extra_fields = {})
      Stripe::Customer.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_customer(customer_id)
      Stripe::Customer.delete customer_id, {}, stripe_opts
    end

    def attach_payment_method(stripe_customer_id, payment_method_id)
      return if stripe_customer_id.nil? || payment_method_id.nil?

      Stripe::PaymentMethod.attach(payment_method_id, { customer: stripe_customer_id })
    end

    private

    def stripe_opts
      raise 'Stripe API key not configured' if Flatirons::Saas.stripe_api_key.nil?

      { api_key: Flatirons::Saas.stripe_api_key }
    end
  end
end
