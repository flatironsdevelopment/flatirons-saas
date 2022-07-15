# frozen_string_literal: true

shared_context 'dummy_user' do
  include_context 'stripe'
  let!(:stripe_customer) { Stripe::Customer.create({ name: 'flatirons', source: stripe_helper.generate_card_token }) }
  let!(:current_dummy_user) do
    DummyUser.create(email: 'flatirons-saas@flatironsdevelopment.com', password: 'Password#12345', stripe_customer_id: stripe_customer.id)
  end
end
