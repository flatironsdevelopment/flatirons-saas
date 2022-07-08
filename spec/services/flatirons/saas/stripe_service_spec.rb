# frozen_string_literal: true

require 'rails_helper'

module Flatirons::Saas::Services
  describe StripeService do
    include_context 'stripe'

    let!(:service) { StripeService.new }

    context 'when stripe API key is not set' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.create_customer 'test' }.to raise_error 'Stripe API key not configured'
      end

      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.destroy_customer 'test' }.to raise_error 'Stripe API key not configured'
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
  end
end
