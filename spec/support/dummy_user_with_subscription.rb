# frozen_string_literal: true

shared_context 'dummy_user_with_subscription' do
  let!(:product) { Flatirons::Saas::Product.create(name: 'Flatirons') }
  let!(:stripe_price) { Stripe::Price.create({ unit_amount: 4000, currency: 'usd', product: product.stripe_product_id }) }
  let!(:subscription) { FactoryBot.create(:subscription, subscriptable: current_dummy_user, product: product, stripe_price_id: stripe_price.id) }
end
