# frozen_string_literal: true

require 'rails_helper'
require 'stripe_mock'

module Flatirons::Saas
  describe StripeService do
    include_context 'stripe'

    let!(:service) { StripeService.new }

    describe 'customer' do
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
  end
end
