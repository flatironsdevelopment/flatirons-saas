# frozen_string_literal: true

require 'rails_helper'

describe Flatirons::Saas::Concerns::Subscriptable do
  include_context 'with_subscriptable_organization_model'

  it 'can be accessed as a constant' do
    expect(Organization).to_not be_nil
  end

  it 'should be subscriptable' do
    expect(Organization.subscriptable?).to be true
  end

  it 'should not include subscriptable twice' do
    expect(Organization.subscriptable).to be_nil
  end

  before(:each) do
    @service = mock_stripe_service
  end

  describe 'stripe integration' do
    let!(:customer) { Stripe::Customer.create({ name: 'organization_1' }) }
    let!(:organization) { Organization.new(name: 'Flatirons', stripe_customer_id: stripe_customer_id) }

    before(:each) do
      allow(@service).to receive(:create_customer).and_return(customer)
    end

    describe 'create_stripe_customer' do
      context 'when stripe customer does not exist' do
        let!(:stripe_customer_id) { nil }

        describe 'customer creation' do
          it 'should create stripe customer' do
            expect(@service).to receive(:create_customer).with(organization.name, {}).and_return(customer)

            organization.save

            expect(organization.stripe_customer_id).to eq(customer.id)
            expect(organization.reload.stripe_customer_id).to eq(customer.id)
          end
        end
      end

      context 'when stripe customer exists' do
        let!(:stripe_customer_id) { customer.id }

        it 'should not create stripe customer' do
          expect(@service).to_not receive(:create_customer)

          organization.save

          expect(organization.stripe_customer_id).to eq(customer.id)
        end
      end

      context 'when stripe_customer_id attribute does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should raise stripe_customer_id attribute not found.' do
          allow(organization).to receive(:has_attribute?).with(:stripe_customer_id).and_return false

          expect { organization.save }.to raise_error 'stripe_customer_id attribute not found.'
        end
      end

      context 'when stripe raise an error' do
        let!(:stripe_customer_id) { nil }

        it 'should not create the organization' do
          expect(@service).to receive(:create_customer).with(organization.name, {}).and_raise('Failed to create the customer')

          expect { organization.save }.to raise_error 'Failed to create the customer'
          expect(Organization.count).to eq 0
        end
      end

      describe 'callbacks' do
        let!(:stripe_customer_id) { nil }
        let!(:callbacks) { spy('callbacks') }

        before(:each) do
          callback_ref = callbacks
          Organization.before_stripe_customer_creation  do
            callback_ref.before_stripe_customer_creation
          end
          Organization.around_stripe_customer_creation  do |_, block|
            block.call
            callback_ref.around_stripe_customer_creation
          end
          Organization.after_stripe_customer_creation  do
            callback_ref.after_stripe_customer_creation
          end
        end

        it 'should run callbacks' do
          expect(@service).to receive(:create_customer).with(organization.name, {}).and_return(customer)

          organization.save

          expect(callbacks).to have_received(:before_stripe_customer_creation)
          expect(callbacks).to have_received(:around_stripe_customer_creation)
          expect(callbacks).to have_received(:after_stripe_customer_creation)

          expect(organization.stripe_customer_id).to eq(customer.id)
          expect(organization.reload.stripe_customer_id).to eq(customer.id)
        end
      end
    end

    describe 'destroy_stripe_customer' do
      context 'when stripe customer does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should not destroy the stripe customer' do
          expect(@service).to_not receive(:destroy_customer)

          organization.destroy
        end
      end

      context 'when stripe customer exists' do
        let!(:stripe_customer_id) { customer.id }

        it 'should destroy the stripe customer' do
          expect(@service).to receive(:destroy_customer).with(stripe_customer_id)

          organization.destroy

          expect(organization.stripe_customer_id).to eq(customer.id)
        end
      end

      context 'when stripe_customer_id attribute does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should raise stripe_customer_id attribute not found.' do
          allow(organization).to receive(:has_attribute?).with(:stripe_customer_id).and_return false

          expect { organization.destroy }.to raise_error 'stripe_customer_id attribute not found.'
        end
      end

      context 'when delete_customer_on_destroy option is not true' do
        let!(:stripe_customer_id) { nil }

        it 'should not destroy the stripe customer' do
          allow(organization).to receive(:subscriptable_options).and_return({})

          expect(@service).to_not receive(:destroy_customer)

          organization.destroy
        end

        it 'should not destroy the stripe customer' do
          allow(organization).to receive(:subscriptable_options).and_return({ delete_customer_on_destroy: false })

          expect(@service).to_not receive(:destroy_customer)

          organization.destroy
        end
      end

      describe 'callbacks' do
        let!(:stripe_customer_id) { customer.id }
        let!(:callbacks) { spy('callbacks') }

        before(:each) do
          callback_ref = callbacks
          Organization.before_stripe_customer_deletion  do
            callback_ref.before_stripe_customer_deletion
          end
          Organization.around_stripe_customer_deletion  do |_, block|
            block.call
            callback_ref.around_stripe_customer_deletion
          end
          Organization.after_stripe_customer_deletion  do
            callback_ref.after_stripe_customer_deletion
          end
        end

        it 'should run callbacks' do
          expect(@service).to receive(:destroy_customer).with(stripe_customer_id)

          organization.destroy

          expect(callbacks).to have_received(:before_stripe_customer_deletion)
          expect(callbacks).to have_received(:around_stripe_customer_deletion)
          expect(callbacks).to have_received(:after_stripe_customer_deletion)

          expect(organization.stripe_customer_id).to eq(customer.id)
        end
      end
    end

    describe 'stripe_customer' do
      context 'when stripe_customer_id is not nil' do
        let!(:stripe_customer_id) { customer.id }

        it 'should retrieve the stripe customer' do
          expect(@service).to receive(:retrieve_customer).with(customer.id).and_return(customer)

          found_stripe_customer = organization.stripe_customer

          expect(found_stripe_customer).to_not be_nil
          expect(found_stripe_customer.id).to eq(customer.id)
        end
      end
      context 'when stripe_customer_id is nil' do
        let!(:stripe_customer_id) { nil }

        it 'should not retrieve the stripe customer' do
          expect(@service).to_not receive(:retrieve_customer).with(customer.id)
          expect(organization.stripe_customer).to be_nil
        end
      end
    end

    describe 'attach_payment_method' do
      let!(:payment_method) { Stripe::PaymentMethod.create(stripe_credit_card) }
      let!(:payment_method_id) { payment_method.id }

      context 'when stripe customer does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should not attach the payment method' do
          expect(@service).to_not receive(:attach_payment_method)

          expect(organization.attach_payment_method(payment_method_id)).to be false
        end
      end

      context 'when stripe customer exists' do
        let!(:stripe_customer_id) { customer.id }

        it 'should attach the payment method' do
          expect(@service).to receive(:attach_payment_method).with(stripe_customer_id, payment_method_id, set_as_default: false).and_return payment_method

          payment_method = organization.attach_payment_method payment_method_id
          expect(payment_method.id).to eq payment_method_id
        end

        it 'should attach the payment method and set as default' do
          expect(@service).to receive(:attach_payment_method).with(stripe_customer_id, payment_method_id, set_as_default: true).and_return payment_method

          payment_method = organization.attach_payment_method payment_method_id, set_as_default: true
          expect(payment_method.id).to eq payment_method_id
        end
      end

      context 'when stripe_customer_id attribute does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should raise stripe_customer_id attribute not found.' do
          allow(organization).to receive(:has_attribute?).with(:stripe_customer_id).and_return false

          expect { organization.attach_payment_method(payment_method_id) }.to raise_error 'stripe_customer_id attribute not found.'
        end
      end
    end

    describe 'payment_methods' do
      let!(:payment_method) { Stripe::PaymentMethod.create(stripe_credit_card) }
      let!(:payment_method_id) { payment_method.id }

      context 'when stripe customer does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should return empty' do
          expect(@service).to_not receive(:list_payment_methods)

          expect(organization.payment_methods).to eq []
        end
      end

      context 'when stripe customer exists' do
        let!(:stripe_customer_id) { customer.id }

        it 'should return the payment methods' do
          expect(@service).to receive(:list_payment_methods).with(stripe_customer_id).and_return [payment_method]

          payment_methods = organization.payment_methods
          expect(payment_methods[0].id).to eq payment_method_id
        end
      end

      context 'when stripe_customer_id attribute does not exist' do
        let!(:stripe_customer_id) { nil }

        it 'should raise stripe_customer_id attribute not found.' do
          allow(organization).to receive(:has_attribute?).with(:stripe_customer_id).and_return false

          expect { organization.payment_methods }.to raise_error 'stripe_customer_id attribute not found.'
        end
      end
    end
  end

  describe 'relationships' do
    let!(:organization) { Organization.create(name: 'Flatirons', stripe_customer_id: 'stripe_customer_id') }

    it 'should return 1' do
      expect(Organization.count).to eq(1)
    end

    describe 'subscriptions' do
      context 'without subscriptions' do
        it 'should return 0' do
          expect(organization.subscriptions.count).to eq(0)
        end
      end

      context 'with subscriptions' do
        before(:each) do
          stripe_return_mocked = Struct.new(:id).new('test_stripe_return_mocked')
          allow(@service).to receive(:create_product).and_return stripe_return_mocked
          allow(@service).to receive(:create_subscription).and_return stripe_return_mocked
          product = FactoryBot.create(:product)
          FactoryBot.create(:subscription, subscriptable: organization, product: product, stripe_price_id: 'test_price_id')
        end

        it 'should return 1' do
          expect(organization.subscriptions.count).to eq(1)
        end
      end
    end
  end

  describe 'validation' do
    let!(:organization) { Organization.new(name: 'Flatirons', stripe_customer_id: 'stripe_customer_id') }

    it 'should validate the presence of stripe_customer_name' do
      allow(organization).to receive(:stripe_customer_name).and_return(nil)
      expect(organization.save).to be false
      expect(organization.errors.full_messages.to_sentence).to eq('stripe_customer_name is required')
    end
  end
end
