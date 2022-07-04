# frozen_string_literal: true

shared_context 'with_subscriptable_organization_model' do
  include_context 'stripe'
  with_model :Organization do
    table do |t|
      t.string :name
      t.string :stripe_customer_id
      t.timestamps null: false
    end

    model do
      validates_presence_of :name
      subscriptable delete_customer_on_destroy: true
    end
  end
end
