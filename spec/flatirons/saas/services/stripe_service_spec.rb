# frozen_string_literal: true

require 'rails_helper'

describe Flatirons::Saas::Services::StripeService do
  include_context 'stripe'

  let!(:service) { Flatirons::Saas::Services::StripeService.new }

  context 'when stripe API key is not set' do
    describe 'create_customer' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.create_customer 'test' }.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'destroy_customer' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.destroy_customer 'test' }.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'attach_payment_method' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.attach_payment_method 'test', 'test' }.to raise_error 'Stripe API key not configured'
      end

      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.attach_payment_method 'test', 'test', set_as_default: true }.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'list_payment_methods' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.list_payment_methods 'test' }.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'create_price' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect do
          service.create_price(product_id: 'product.id',
                               unit_amount: 'unit_amount',
                               currency: 'currency')
        end.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'list_prices' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.list_prices('product.id') }.to raise_error 'Stripe API key not configured'
      end
    end
  end

  describe 'customer' do
    describe 'create_customer' do
      let!(:customer_name) { 'Flatirons' }

      it 'should create a stripe customer' do
        customer = service.create_customer customer_name
        expect(customer.name).to eq(customer_name)
        expect(customer.id).to_not be_nil
      end

      context 'given extra fields' do
        let!(:customer_email) { 'flatirons@flatironsdevelopment.com' }
        it 'should create a stripe customer' do
          customer = service.create_customer customer_name, { email: customer_email }
          expect(customer.name).to eq(customer_name)
          expect(customer.email).to eq(customer_email)
          expect(customer.id).to_not be_nil
        end
      end
    end

    describe 'destroy_customer' do
      let!(:customer) { Stripe::Customer.create({ name: 'flatirons' }) }

      it 'should destroy the stripe customer' do
        expect(Stripe::Customer.retrieve(customer.id).deleted?).to be false

        deleted_customer = service.destroy_customer(customer.id)
        expect(deleted_customer.deleted?).to be true

        expect(Stripe::Customer.retrieve(customer.id).deleted?).to be true
      end
    end
  end

  describe 'payment method' do
    describe 'attach_payment_method' do
      context 'given a customer' do
        let!(:stripe_customer_id) { Stripe::Customer.create({ name: 'Flatirons Test' }).id }

        context 'given a payment method' do
          let!(:payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }

          it 'should attach a payment method' do
            payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id)
            expect(payment_method).to_not be_nil
            expect(payment_method.id).to eq(payment_method_id)
          end

          describe 'set_as_default' do
            it 'should set as default the payment method' do
              payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id, set_as_default: true)
              expect(payment_method).to_not be_nil
              expect(payment_method.id).to eq(payment_method_id)

              updated_customer = Stripe::Customer.retrieve(stripe_customer_id)
              expect(updated_customer.invoice_settings.default_payment_method).to eq payment_method_id
            end
          end
        end

        context 'given a nil payment method' do
          let!(:payment_method_id) { nil }

          it 'should not attach a payment method' do
            payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id)
            expect(payment_method).to be_nil
          end
        end
      end
      context 'given a nil customer' do
        let!(:stripe_customer_id) { nil }

        context 'given a payment method' do
          let!(:payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }

          it 'should not attach a payment method' do
            payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id)
            expect(payment_method).to be_nil
          end
        end
      end
    end

    describe 'list_payment_methods' do
      context 'given a customer with payment methods' do
        let!(:stripe_customer_id) { Stripe::Customer.create({ name: 'Flatirons Test' }).id }
        let!(:first_payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }
        let!(:second_payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }

        before(:each) do
          stripe_opts = { api_key: 'test' }
          Stripe::PaymentMethod.attach(first_payment_method_id, { customer: stripe_customer_id }, stripe_opts)
          Stripe::PaymentMethod.attach(second_payment_method_id, { customer: stripe_customer_id }, stripe_opts)
        end

        it 'should list the payment methods' do
          payment_methods = service.list_payment_methods stripe_customer_id

          expect(payment_methods[0].id).to eq(first_payment_method_id)
          expect(payment_methods[1].id).to eq(second_payment_method_id)
        end
      end

      context 'without customer' do
        it 'should be nil' do
          expect(service.list_payment_methods(nil)).to be_nil
        end
      end
    end
  end

  describe 'product' do
    describe 'create_product' do
      let!(:product_name) { 'Flatirons' }

      it 'should create a product' do
        product = service.create_product product_name
        expect(product.id).to_not be_nil
        expect(product.name).to eq product_name
      end

      context 'given extra fields' do
        let!(:extra_fields) { { description: 'Flatirons Product Description' } }

        it 'should create a product' do
          product = service.create_product product_name, extra_fields
          expect(product.id).to_not be_nil
          expect(product.name).to eq product_name
          expect(product.description).to eq extra_fields[:description]
        end
      end
    end

    describe 'destroy_product' do
      let!(:product) { Stripe::Product.create({ name: 'flatirons' }) }

      it 'should destroy the product' do
        expect(Stripe::Product.retrieve(product.id).deleted?).to be false

        deleted_product = service.destroy_product(product.id)
        expect(deleted_product.deleted?).to be true

        expect { Stripe::Product.retrieve(product.id) }.to raise_error "No such product: #{product.id}"
      end
    end
  end

  describe 'price' do
    describe 'create_price' do
      context 'given a product' do
        let!(:product) { Stripe::Product.create({ name: 'Beer' }) }
        let!(:unit_amount) { 1099 }
        let!(:currency) { 'usd' }
        let!(:recurring_interval) { 'month' }

        it 'should create a price' do
          price = service.create_price(
            product_id: product.id,
            unit_amount: unit_amount,
            currency: currency,
            recurring_interval: recurring_interval
          )
          expect(price).to_not be_nil
          expect(price.id).to_not be_nil
          expect(price.recurring.interval).to eq recurring_interval
          expect(price.unit_amount).to eq unit_amount
          expect(price.currency).to eq currency
        end

        it 'should create a price without recurring_interval' do
          price = service.create_price(
            product_id: product.id,
            unit_amount: unit_amount,
            currency: currency
          )
          expect(price).to_not be_nil
          expect(price.id).to_not be_nil
          expect(price.unit_amount).to eq unit_amount
          expect(price.currency).to eq currency
        end
      end

      context 'invalid paramenters' do
        let!(:product) { Stripe::Product.create({ name: 'Beer' }) }

        it 'should not create a price without product_id' do
          price = service.create_price(
            product_id: nil,
            unit_amount: 100,
            currency: 'usd'
          )
          expect(price).to be_nil
        end

        it 'should not create a price without unit_amount' do
          price = service.create_price(
            product_id: product.id,
            unit_amount: nil,
            currency: 'usd'
          )
          expect(price).to be_nil
        end

        it 'should not create a price without unit_amount' do
          price = service.create_price(
            product_id: product.id,
            unit_amount: 900,
            currency: nil
          )
          expect(price).to be_nil
        end
      end
    end

    describe 'list_prices' do
      context 'given a product with prices' do
        let!(:product) { Stripe::Product.create({ name: 'Beer' }) }
        let!(:first_price) do
          Stripe::Price.create({
                                 unit_amount: 4000,
                                 currency: 'usd',
                                 product: product.id,
                               })
        end
        let!(:second_price) do
          Stripe::Price.create({
                                 unit_amount: 4000,
                                 currency: 'usd',
                                 product: product.id,
                               })
        end

        it 'should list prices to given product' do
          prices = service.list_prices(product.id)
          expect(prices).to_not be_nil
          expect(prices.size).to eq 2
          expect(prices[1].id).to eq(first_price.id)
          expect(prices[0].id).to eq(second_price.id)
        end
      end

      context 'invalid parameters' do
        it 'should not list prices' do
          prices = service.list_prices(nil)
          expect(prices).to be_nil
        end
      end
    end
  end
end
