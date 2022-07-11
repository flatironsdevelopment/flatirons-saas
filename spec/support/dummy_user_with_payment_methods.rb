# frozen_string_literal: true

shared_context 'dummy_user_with_payment_methods' do
  let!(:subscription) { FactoryBot.create(:subscription, subscriptable: current_dummy_user) }

  let!(:first_payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }
  let!(:second_payment_method_id) { Stripe::PaymentMethod.create(stripe_credit_card).id }

  before(:each) do
    stripe_opts = { api_key: 'test' }
    Stripe::PaymentMethod.attach(first_payment_method_id, { customer: current_dummy_user.stripe_customer_id }, stripe_opts)
    Stripe::PaymentMethod.attach(second_payment_method_id, { customer: current_dummy_user.stripe_customer_id }, stripe_opts)
  end
end
