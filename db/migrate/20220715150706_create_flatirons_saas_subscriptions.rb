class CreateFlatironsSaasSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :flatirons_saas_subscriptions do |t|
      t.string :stripe_subscription_id, null: false
      t.string :stripe_price_id, null: false
      t.string :status, null: false
      t.references :subscriptable, polymorphic: true
      t.references :product, polymorphic: true
      t.timestamp :deleted_at
      t.timestamp :canceled_at
      t.timestamps
    end
    add_index :flatirons_saas_subscriptions, :stripe_subscription_id, unique: true
    add_index :flatirons_saas_subscriptions, :stripe_price_id
    add_index :flatirons_saas_subscriptions, :status
    add_index :flatirons_saas_subscriptions, :deleted_at
  end
end
