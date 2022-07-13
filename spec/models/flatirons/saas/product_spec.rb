# frozen_string_literal: true

require 'rails_helper'

module Flatirons::Saas
  RSpec.describe Product, type: :model do
    include_context 'stripe'

    describe 'validations' do
      it { should validate_presence_of(:name) }
    end

    describe 'create_stripe_product' do
      let!(:stripe_product) { Stripe::Product.create({ name: 'Flatirons' }) }
      let!(:description) { 'My amazing product' }
      let!(:product) { Product.new(name: 'Flatirons', description: description) }

      describe 'product creation' do
        it 'should create stripe product with description' do
          service = instance_double(Flatirons::Saas::Services::StripeService)
          allow(Flatirons::Saas::Services::StripeService).to receive(:new).and_return(service)
          expect(service).to receive(:create_product).with(product.name, { description: description }).and_return(stripe_product)

          product.save!

          expect(product.stripe_product_id).to eq(stripe_product.id)
          expect(product.reload.stripe_product_id).to eq(stripe_product.id)
        end
      end
    end
  end
end
