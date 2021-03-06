# frozen_string_literal: true

class CreateDummyUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :dummy_users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Subscriptable
      t.string :stripe_customer_id, unique: true, null: false

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamp :deleted_at
      t.timestamps null: false

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end
  end
end
