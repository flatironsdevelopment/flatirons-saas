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

    belongs_to :subscriptable, polymorphic: true
    validates :stripe_subscription_id, presence: true, uniqueness: true
    validates :status, presence: true, inclusion: { in: statuses }

    enum status: { active: 'active', cancelled: 'cancelled' }
  end
end
