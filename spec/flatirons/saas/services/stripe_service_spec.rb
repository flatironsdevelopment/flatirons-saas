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
  end

  describe 'customer' do
    describe 'create_customer' do
      let!(:customer_name) { 'Flatirons' }

      it 'should create a stripe customer' do
        customer = service.create_customer customer_name
        expect(customer.name).to eq(customer_name)
        expect(customer.id).to be
      end

      context 'given extra fields' do
        let!(:customer_email) { 'flatirons@flatironsdevelopment.com' }
        it 'should create a stripe customer' do
          customer = service.create_customer customer_name, { email: customer_email }
          expect(customer.name).to eq(customer_name)
          expect(customer.email).to eq(customer_email)
          expect(customer.id).to be
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
            expect(payment_method).to be
            expect(payment_method.id).to eq(payment_method_id)
          end

          describe 'set_as_default' do
            it 'should set as default the payment method' do
              payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id, set_as_default: true)
              expect(payment_method).to be
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
            expect(payment_method).to_not be
          end
        end
      end
      context 'given a nil customer' do
        let!(:stripe_customer_id) { nil }

        context 'given a payment method' do
          let!(:payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }

          it 'should not attach a payment method' do
            payment_method = service.attach_payment_method(stripe_customer_id, payment_method_id)
            expect(payment_method).to_not be
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
        it 'should not be' do
          expect(service.list_payment_methods(nil)).to_not be
        end
      end
    end
  end
end
