# frozen_string_literal: true

class CreateTests < ActiveRecord::Migration[6.1]
  def change
    create_table :tests do |t|
      t.string :name, index: true, null: false
      t.string :stripe_product_id, index: true, unique: true, null: false

      t.timestamps
    end
  end
end
