# frozen_string_literal: true

module Flatirons::Saas
  class Subscription < ApplicationRecord
    soft_deletable

    belongs_to :subscriptable, polymorphic: true
    validates :stripe_subscription_id, presence: true, uniqueness: true
    validates :status, presence: true

    enum status: { active: 'active', cancelled: 'cancelled' }
  end
end
