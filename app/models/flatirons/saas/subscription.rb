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
    include Flatirons::Saas::Concerns::Stripe

    enum status: { active: 'active', cancelled: 'cancelled' }

    belongs_to :product, polymorphic: true
    belongs_to :subscriptable, polymorphic: true
    validates :stripe_price_id, presence: true
    validates :status, presence: true, inclusion: { in: statuses }
    validate :stripe_customer_id, on: :create

    before_create :create_stripe_subscription, prepend: true
    before_update :update_stripe_subscription, prepend: true

    private

    def stripe_customer_id
      errors.add(:subscriptable, 'stripe_customer_id is required') unless subscriptable&.stripe_customer_id
    end

    def create_stripe_subscription
      subscription = stripe_service.create_subscription(subscriptable.stripe_customer_id, stripe_price_id)
      self[:stripe_subscription_id] = subscription.id
    end

    def update_stripe_subscription
      stripe_service.update_subscription stripe_subscription_id, stripe_price_id if stripe_price_id_changed?
    end
  end
end
