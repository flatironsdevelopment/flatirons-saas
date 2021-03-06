# frozen_string_literal: true

require 'rails_helper'

describe Flatirons::Saas::Concerns::Productable do
  include_context 'with_productable_plan_model'

  it 'can be accessed as a constant' do
    expect(Plan).to_not be_nil
  end

  it 'should be productable' do
    expect(Plan.productable?).to be true
  end

  it 'should not include productable twice' do
    expect(Plan.productable).to be_nil
  end

  describe 'stripe integration' do
    let!(:product) { Stripe::Product.create({ name: 'plan_1' }) }
    let!(:plan) { Plan.new(name: 'Flatirons', stripe_product_id: stripe_product_id) }

    before(:each) do
      @service = mock_stripe_service
    end

    describe 'create_stripe_product' do
      context 'when stripe product does not exist' do
        let!(:stripe_product_id) { nil }

        describe 'product creation' do
          it 'should create stripe product' do
            expect(@service).to receive(:create_product).with(plan.name, {}).and_return(product)

            plan.save!

            expect(plan.stripe_product_id).to eq(product.id)
            expect(plan.reload.stripe_product_id).to eq(product.id)
          end
        end
      end

      context 'when stripe product exist' do
        let!(:stripe_product_id) { product.id }

        it 'should not create stripe product' do
          expect(@service).to_not receive(:create_product)

          plan.save

          expect(plan.stripe_product_id).to eq(product.id)
        end
      end

      context 'when stripe_product_id attribute does not exist' do
        let!(:stripe_product_id) { nil }

        it 'should raise stripe_product_id attribute not found.' do
          allow(plan).to receive(:has_attribute?).with(:stripe_product_id).and_return false

          expect { plan.save }.to raise_error 'stripe_product_id attribute not found.'
        end
      end

      context 'when stripe raise an error' do
        let!(:stripe_product_id) { nil }

        it 'should not create the product' do
          expect(@service).to receive(:create_product).with(plan.name, {}).and_raise('Failed to create the product')

          expect { plan.save }.to raise_error 'Failed to create the product'
          expect(Plan.count).to eq 0
        end
      end

      describe 'callbacks' do
        let!(:stripe_product_id) { nil }
        let!(:callbacks) { spy('callbacks') }

        before(:each) do
          callback_ref = callbacks
          Plan.before_stripe_product_creation  do
            callback_ref.before_stripe_product_creation
          end
          Plan.around_stripe_product_creation  do |_, block|
            block.call
            callback_ref.around_stripe_product_creation
          end
          Plan.after_stripe_product_creation  do
            callback_ref.after_stripe_product_creation
          end
        end

        it 'should run callbacks' do
          expect(@service).to receive(:create_product).with(plan.name, {}).and_return(product)

          plan.save

          expect(callbacks).to have_received(:before_stripe_product_creation)
          expect(callbacks).to have_received(:around_stripe_product_creation)
          expect(callbacks).to have_received(:after_stripe_product_creation)

          expect(plan.stripe_product_id).to eq(product.id)
          expect(plan.reload.stripe_product_id).to eq(product.id)
        end
      end
    end

    describe 'destroy_stripe_product' do
      context 'when stripe product does not exist' do
        let!(:stripe_product_id) { nil }

        it 'should not destroy the stripe product' do
          expect(@service).to_not receive(:destroy_product)

          plan.destroy
        end
      end

      context 'when stripe product exist' do
        let!(:stripe_product_id) { product.id }

        it 'should destroy the stripe product' do
          expect(@service).to receive(:destroy_product).with(stripe_product_id)

          plan.destroy

          expect(plan.stripe_product_id).to eq(product.id)
        end
      end

      context 'when stripe_product_id attribute does not exist' do
        let!(:stripe_product_id) { nil }

        it 'should raise stripe_product_id attribute not found.' do
          allow(plan).to receive(:has_attribute?).with(:stripe_product_id).and_return false

          expect { plan.destroy }.to raise_error 'stripe_product_id attribute not found.'
        end
      end

      context 'when delete_product_on_destroy option is not true' do
        let!(:stripe_product_id) { nil }

        it 'should not destroy the stripe product' do
          allow(plan).to receive(:productable_options).and_return({})

          expect(@service).to_not receive(:destroy_product)

          plan.destroy
        end

        it 'should not destroy the stripe product' do
          allow(plan).to receive(:productable_options).and_return({ delete_product_on_destroy: false })

          expect(@service).to_not receive(:destroy_product)

          plan.destroy
        end
      end

      describe 'callbacks' do
        let!(:stripe_product_id) { product.id }
        let!(:callbacks) { spy('callbacks') }

        before(:each) do
          callback_ref = callbacks
          Plan.before_stripe_product_deletion  do
            callback_ref.before_stripe_product_deletion
          end
          Plan.around_stripe_product_deletion  do |_, block|
            block.call
            callback_ref.around_stripe_product_deletion
          end
          Plan.after_stripe_product_deletion  do
            callback_ref.after_stripe_product_deletion
          end
        end

        it 'should run callbacks' do
          expect(@service).to receive(:destroy_product).with(stripe_product_id)

          plan.destroy

          expect(callbacks).to have_received(:before_stripe_product_deletion)
          expect(callbacks).to have_received(:around_stripe_product_deletion)
          expect(callbacks).to have_received(:after_stripe_product_deletion)

          expect(plan.stripe_product_id).to eq(product.id)
        end
      end
    end

    describe 'stripe_product' do
      context 'when stripe_product_id is not nil' do
        let!(:stripe_product_id) { product.id }

        it 'should retrieve the stripe product' do
          expect(@service).to receive(:retrieve_product).with(product.id).and_return(product)

          found_stripe_product = plan.stripe_product

          expect(found_stripe_product).to_not be_nil
          expect(found_stripe_product.id).to eq(product.id)
        end
      end
      context 'when stripe_product_id is nil' do
        let!(:stripe_product_id) { nil }

        it 'should not retrieve the stripe product' do
          expect(@service).to_not receive(:retrieve_product).with(product.id)
          expect(plan.stripe_product).to be_nil
        end
      end
    end

    describe 'create_price' do
      let!(:price) { Stripe::Price.create({ unit_amount: 4000, currency: 'usd', product: product.id, }) }

      let!(:unit_amount) { 1099 }
      let!(:currency) { 'usd' }
      let!(:recurring_interval) { 'month' }

      context 'when stripe product exist' do
        let!(:stripe_product_id) { product.id }

        it 'should create a price' do
          expect(@service).to receive(:create_price).with(product_id: stripe_product_id, unit_amount: unit_amount,  currency: currency,
                                                          recurring_interval: recurring_interval, extra_fields: {}).and_return(price)

          new_price = plan.create_price(unit_amount: unit_amount, currency: currency, recurring_interval: recurring_interval)

          expect(new_price).to_not be_nil
          expect(new_price.id).to eq price.id
        end
      end

      context 'when stripe product does not exist' do
        let!(:stripe_product_id) { nil }

        it 'it should not create the price.' do
          expect(@service).to_not receive(:create_price)

          price = plan.create_price(unit_amount: unit_amount,  currency: currency, recurring_interval: recurring_interval)
          expect(price).to be_nil
        end
      end

      context 'when stripe_product_id attribute does not exist' do
        let!(:stripe_product_id) { nil }

        it 'should raise stripe_product_id attribute not found.' do
          expect(@service).to_not receive(:create_price)

          allow(plan).to receive(:has_attribute?).with(:stripe_product_id).and_return false

          expect do
            plan.create_price(unit_amount: unit_amount, currency: currency,
                              recurring_interval: recurring_interval)
          end.to raise_error 'stripe_product_id attribute not found.'
        end
      end
    end

    describe 'prices' do
      let!(:price) { Stripe::Price.create({ unit_amount: 4000, currency: 'usd', product: product.id, }) }

      context 'when stripe product exist' do
        let!(:stripe_product_id) { product.id }

        it 'should list prices' do
          expect(@service).to receive(:list_prices).with(stripe_product_id).and_return([price])

          prices = plan.prices

          expect(prices.size).to eq 1
          expect(prices[0]).to_not be_nil
          expect(prices[0].id).to eq price.id
        end
      end

      context 'when stripe product does not exist' do
        let!(:stripe_product_id) { nil }

        it 'it should not list prices.' do
          expect(@service).to_not receive(:list_prices)

          price = plan.prices
          expect(price).to be_nil
        end
      end

      context 'when stripe_product_id attribute does not exist' do
        let!(:stripe_product_id) { nil }

        it 'should raise stripe_product_id attribute not found.' do
          expect(@service).to_not receive(:list_prices)

          allow(plan).to receive(:has_attribute?).with(:stripe_product_id).and_return false
          expect { plan.prices }.to raise_error 'stripe_product_id attribute not found.'
        end
      end
    end
  end

  describe 'validation' do
    let!(:plan) { Plan.new(name: 'Flatirons', stripe_product_id: 'stripe_product_id') }

    it 'should validate the presence of stripe_product_name' do
      allow(plan).to receive(:stripe_product_name).and_return(nil)
      expect(plan.save).to be false
      expect(plan.errors.full_messages.to_sentence).to eq('stripe_product_name is required')
    end
  end
end
