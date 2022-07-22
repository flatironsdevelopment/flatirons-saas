# frozen_string_literal: true

class DummyUser < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  soft_deletable
  subscriptable

  def stripe_customer_name
    email
  end
end
