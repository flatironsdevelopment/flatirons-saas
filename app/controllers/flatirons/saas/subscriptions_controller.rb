# frozen_string_literal: true

module Flatirons::Saas
  class SubscriptionsController < ApplicationController
    before_action :authenticate!
    before_action :find_product, only: %i[create update]
    before_action :find_subscription, only: [:update]

    # GET /resource/subscriptions
    def index
      render json: @current_resource.subscriptions
    end

    # POST /resource/subscriptions
    def create
      subscription = @current_resource.subscriptions.create(product: @product, stripe_price_id: subscription_params[:stripe_price_id], status: :active)
      if subscription.save
        render json: subscription
      else
        render json: { errors: subscription.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    # PUT /resource/subscriptions/{id}
    def update
      if @subscrption.update(product: @product, stripe_price_id: subscription_params[:stripe_price_id])
        render json: @subscrption
      else
        render json: { errors: @subscrption.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    private

    def subscription_params
      params.permit(:stripe_price_id, :product_id)
    end

    def find_subscription
      @subscrption = Subscription.find_by(id: params[:id])

      render json: { message: 'Subscription not found' }, status: :not_found if @subscrption.blank?
    end

    def find_product
      product_klass = mapping[:productable_klass]

      @product = product_klass.find_by(id: subscription_params[:product_id])

      render json: { message: 'Product not found' }, status: :not_found if @product.blank?
    end
  end
end
