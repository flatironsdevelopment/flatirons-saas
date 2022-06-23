# frozen_string_literal: true

class AddInitialData < ActiveRecord::Migration[6.1]
  def up
    user = DummyUser.create(email: 'dummy.user@flatironsdevelopment.com', password: 'Password#123456')
    subscription = Flatirons::Saas::Subscription.create(subscriptable: user, status: 'active', stripe_subscription_id: 'dummy_test')
  end

  def down
    DummyUser.delete_all
    Flatirons::Saas::Subscription.delete_all
  end
end
