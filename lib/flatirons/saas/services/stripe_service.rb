# frozen_string_literal: true

module Flatirons::Saas::Services
  class StripeService
    def create_customer(name, extra_fields = {})
      Stripe::Customer.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_customer(customer_id)
      Stripe::Customer.delete customer_id, {}, stripe_opts
    end

    def retrieve_customer(customer_id)
      Stripe::Customer.retrieve(customer_id, stripe_opts)
    end

    def attach_payment_method(customer_id, payment_method_id, set_as_default: false)
      return unless customer_id && payment_method_id

      set_default_payment_method(customer_id, payment_method_id) if set_as_default

      Stripe::PaymentMethod.attach(payment_method_id, { customer: customer_id }, stripe_opts)
    end

    def list_payment_methods(customer_id)
      return unless customer_id

      Stripe::PaymentMethod.list(
        { customer: customer_id, type: 'card' },
        stripe_opts
      ).data
    end

    def create_product(name, extra_fields = {})
      Stripe::Product.create extra_fields.merge({ name: name }), stripe_opts
    end

    def destroy_product(product_id)
      Stripe::Product.delete product_id, {}, stripe_opts
    end

    def retrieve_product(product_id)
      Stripe::Product.retrieve(product_id, stripe_opts)
    end

    def create_price(product_id:, unit_amount:, currency:, recurring_interval: nil, extra_fields: {})
      return unless product_id && unit_amount && currency

      price_attrs = {
        unit_amount: unit_amount,
        currency: currency,
        product: product_id,
      }
      price_attrs = price_attrs.merge({ recurring: { interval: recurring_interval } }) if recurring_interval

      Stripe::Price.create price_attrs.merge(extra_fields), stripe_opts
    end

    def list_prices(product_id)
      return unless product_id

      Stripe::Price.list({ product: product_id }, stripe_opts).data
    end

    def retrieve_subscription(subscription_id)
      Stripe::Subscription.retrieve(subscription_id, stripe_opts)
    end

    def create_subscription(customer_id, price_id)
      return unless customer_id && price_id

      subscription_params = { customer: customer_id, items: [{ price: price_id }], expand: ['latest_invoice.payment_intent'] }
      Stripe::Subscription.create subscription_params, stripe_opts
    end

    def update_subscription(subscription_id, price_id, proration_behavior = 'always_invoice')
      return unless subscription_id && price_id

      items_to_remove = Stripe::SubscriptionItem.list({ subscription: subscription_id }).data

      subscription_params = {
        proration_behavior: proration_behavior,
        items: [{ price: price_id }]
      }

      subscription = Stripe::Subscription.update(subscription_id, subscription_params, stripe_opts)

      items_to_remove.each { |item| Stripe::SubscriptionItem.delete(item.id) }

      subscription
    end

    def delete_subscription(subscription_id, invoice_now: false, prorate: false)
      return unless subscription_id

      Stripe::Subscription.delete(subscription_id, { invoice_now: invoice_now, prorate: prorate }, stripe_opts)
    end

    private

    def set_default_payment_method(customer_id, payment_method_id)
      settings = {
        invoice_settings: {
          default_payment_method: payment_method_id
        }
      }
      Stripe::Customer.update(
        customer_id,
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
