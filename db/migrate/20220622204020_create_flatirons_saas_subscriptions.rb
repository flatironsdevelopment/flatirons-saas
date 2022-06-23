class CreateFlatironsSaasSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :flatirons_saas_subscriptions do |t|
      t.string :stripe_subscription_id, null: false
      t.string :status, null: false
      t.references :subscriptable, polymorphic: true
      t.timestamp :deleted_at
    end
    add_index :flatirons_saas_subscriptions, :stripe_subscription_id, unique: true
    add_index :flatirons_saas_subscriptions, :status
    add_index :flatirons_saas_subscriptions, :deleted_at
  end
end
