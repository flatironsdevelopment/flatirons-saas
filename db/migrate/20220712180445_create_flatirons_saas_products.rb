class CreateFlatironsSaasProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :flatirons_saas_products do |t|
      t.string :name, index: true, null: false
      t.string :stripe_product_id, index: true, unique: true, null: false
      t.text :description
      t.timestamp :deleted_at
      
      t.timestamps
    end
  end
end
