# frozen_string_literal: true

module Flatirons::Saas
  class SubscriptionsController < ApplicationController
    before_action :authenticate!
    before_action :find_product, only: [:create]

    # GET /resource/subscriptions
    def index
      render json: @current_resource.subscriptions
    end

    # POST /resource/subscriptions
    def create
      subscription = @current_resource.subscriptions.create(product: @product, stripe_price_id: params[:stripe_price_id], status: :active)
      if subscription.save
        render json: subscription
      else
        render json: { errors: subscription.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    def find_product
      product_klass = mapping[:productable_klass]

      @product = product_klass.find_by(id: params[:product_id])

      render json: { message: 'Product not found' }, status: :not_found if @product.blank?
    end
  end
end
