# frozen_string_literal: true

require 'rails_helper'

module Flatirons::Saas
  RSpec.describe Subscription, type: :model do
    describe 'validations' do
      it { should validate_presence_of(:stripe_price_id) }
      it { should validate_presence_of(:status) }
    end

    describe 'relationships' do
      it { is_expected.to have_db_column(:subscriptable_id).of_type(:integer) }
      it { is_expected.to have_db_column(:subscriptable_type).of_type(:string) }
      it { is_expected.to belong_to(:subscriptable) }
      it { is_expected.to have_db_column(:product_id).of_type(:integer) }
      it { is_expected.to have_db_column(:product_type).of_type(:string) }
      it { is_expected.to belong_to(:product) }
    end

    describe 'stripe integration' do
      let!(:stripe_mock_class) { Struct.new(:id) }
      let!(:stripe_customer) { stripe_mock_class.new('customer_1') }
      let!(:stripe_product) { stripe_mock_class.new('product_id') }
      let!(:stripe_price) { stripe_mock_class.new('price_1') }
      let!(:stripe_subscription) { stripe_mock_class.new('test_sub_id') }
      let!(:subscriptable) do
        DummyUser.create(email: 'flatirons-saas@flatironsdevelopment.com', password: 'Password#12345', stripe_customer_id: stripe_customer.id)
      end
      let!(:product) { Flatirons::Saas::Product.create(name: 'Flatirons', stripe_product_id: stripe_product.id) }

      before(:each) do
        @service = mock_stripe_service
        allow(@service).to receive(:create_customer).and_return(stripe_customer)
        allow(@service).to receive(:create_product).and_return(stripe_product)
        allow(@service).to receive(:create_subscription).with(stripe_customer.id, stripe_price.id).and_return(stripe_subscription)
      end

      context 'given a subscriptable and product and price' do
        it 'should create a subscription on database and stripe' do
          expect(@service).to receive(:create_subscription).with(stripe_customer.id, stripe_price.id)

          subscription = Subscription.create(subscriptable: subscriptable, product: product, stripe_price_id: stripe_price.id, status: :active)

          expect(subscription.id).to_not be_nil
          expect(subscription.errors.size).to eq 0
          expect(subscription.stripe_subscription_id).to_not be_nil
          expect(subscription.stripe_price_id).to eq stripe_price.id
          expect(Subscription.count).to eq 1
        end
      end

      context 'invalid parameters' do
        context 'given a subscriptable without stripe_customer_id' do
          it 'should not create a subscription' do
            expect(@service).to_not receive(:create_subscription).with(stripe_customer.id, stripe_price.id)
            allow(subscriptable).to receive(:stripe_customer_id).and_return nil

            subscription = Subscription.create(subscriptable: subscriptable, product: product, stripe_price_id: stripe_price.id, status: :active)

            expect(subscription.id).to be_nil
            expect(subscription.stripe_subscription_id).to be_nil
            expect(subscription.errors.size).to eq 1
            expect(subscription.errors.full_messages.to_sentence).to eq 'Subscriptable stripe_customer_id is required'
            expect(Subscription.count).to eq 0
          end
        end
      end

      context 'given a subscription' do
        let!(:subscription) { Subscription.create(subscriptable: subscriptable, product: product, stripe_price_id: stripe_price.id, status: :active) }
        let!(:new_stripe_price_id) { 'test_new_price' }

        context 'with same stripe_price_id' do
          it 'should update not update the stripe subscription' do
            expect(Subscription.count).to eq 1
            expect(@service).to_not receive(:update_subscription).with(stripe_subscription.id, stripe_price.id)

            subscription.update(stripe_price_id: stripe_price.id)

            expect(subscription.errors.size).to eq 0
            expect(subscription.stripe_price_id).to eq(stripe_price.id)
          end
        end

        context 'with a new stripe_price_id' do
          it 'should update the stripe subscription' do
            expect(Subscription.count).to eq 1
            expect(@service).to receive(:update_subscription).with(stripe_subscription.id, new_stripe_price_id)

            subscription.update(stripe_price_id: new_stripe_price_id)

            expect(subscription.errors.size).to eq 0
            expect(subscription.stripe_price_id).to eq(new_stripe_price_id)
          end
        end
      end
    end
  end
end
