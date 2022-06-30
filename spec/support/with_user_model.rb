# frozen_string_literal: true

shared_context 'with_user_model' do
  with_model :User do
    table do |t|
      t.string :name, null: false

      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamp :deleted_at
      t.timestamps null: false

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end

    model do
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable
      soft_deletable
    end
  end
  let!(:current_user) { User.create(name: 'Flatirons Saas', email: 'flatirons-saas@flatironsdevelopment.com', password: 'Password#12345') }
end
