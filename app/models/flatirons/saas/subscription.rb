# frozen_string_literal: true

module Flatirons::Saas
  # Subscription Active Record
  #
  # == Examples
  #
  #   # get all subscriptions
  #   Flatirons::Saas:Subscription.all
  #
  class Subscription < ApplicationRecord
    soft_deletable

    enum status: { active: 'active', cancelled: 'cancelled' }

    belongs_to :subscriptable, polymorphic: true
    validates :stripe_subscription_id, presence: true, uniqueness: true
    validates :status, presence: true, inclusion: { in: statuses }
  end
end
