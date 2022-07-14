# frozen_string_literal: true

module Flatirons::Saas::Services
  class StripeService
    def create_customer(name, extra_fields = {})
      Stripe::Customer.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_customer(stripe_customer_id)
      Stripe::Customer.delete stripe_customer_id, {}, stripe_opts
    end

    def attach_payment_method(stripe_customer_id, payment_method_id, set_as_default: false)
      return if stripe_customer_id.nil? || payment_method_id.nil?

      set_default_payment_method(stripe_customer_id, payment_method_id) if set_as_default

      Stripe::PaymentMethod.attach(payment_method_id, { customer: stripe_customer_id }, stripe_opts)
    end

    def list_payment_methods(stripe_customer_id)
      return unless stripe_customer_id

      Stripe::PaymentMethod.list(
        { customer: stripe_customer_id, type: 'card' },
        stripe_opts
      ).data
    end

    def create_product(name, extra_fields = {})
      Stripe::Product.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_product(product_id)
      Stripe::Product.delete product_id, {}, stripe_opts
    end

    def create_price(product_id:, unit_amount:, currency:, recurring_interval:, extra_fields: {})
      return if product_id.nil? || unit_amount.nil? || currency.nil?

      price_attrs = {
        unit_amount: unit_amount,
        currency: currency,
        product: product_id,
      }
      price_attrs = price_attrs.merge({ recurring: { interval: recurring_interval } }) if recurring_interval

      Stripe::Price.create price_attrs.merge(extra_fields), stripe_opts
    end

    private

    def set_default_payment_method(stripe_customer_id, payment_method_id)
      settings = {
        invoice_settings: {
          default_payment_method: payment_method_id
        }
      }
      Stripe::Customer.update(
        stripe_customer_id,
        settings,
        stripe_opts
      )
    end

    def stripe_opts
      raise 'Stripe API key not configured' if Flatirons::Saas.stripe_api_key.nil?

      { api_key: Flatirons::Saas.stripe_api_key }
    end
  end
end
