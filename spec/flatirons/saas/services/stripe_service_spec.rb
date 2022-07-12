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

    describe 'create_product' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.create_product 'test' }.to raise_error 'Stripe API key not configured'
      end
    end

    describe 'destroy_product' do
      it 'should raise an error' do
        allow(Flatirons::Saas).to receive(:stripe_api_key).and_return(nil)
        expect { service.destroy_product 'test' }.to raise_error 'Stripe API key not configured'
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

  describe 'product' do
    describe 'create_product' do
      let!(:product_name) { 'Flatirons' }

      it 'should create a product' do
        product = service.create_product product_name
        expect(product.id).to be
        expect(product.name).to eq product_name
      end

      context 'given extra fields' do
        let!(:extra_fields) { { description: 'Flatirons Product Description' } }

        it 'should create a product' do
          product = service.create_product product_name, extra_fields
          expect(product.id).to be
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
end
