# frozen_string_literal: true

shared_context 'with_productable_plan_model' do
  include_context 'stripe'

  with_model :Plan do
    table do |t|
      t.string :name
      t.string :stripe_product_id
      t.timestamps null: false
    end

    model do
      productable delete_product_on_destroy: true
    end
  end
end
