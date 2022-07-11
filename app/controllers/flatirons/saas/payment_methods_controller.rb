# frozen_string_literal: true

module Flatirons::Saas
  class PaymentMethodsController < ApplicationController
    before_action :authenticate!

    # GET /resource/payment_methods
    def index
      render json: @current_resource.payment_methods
    end

    # POST /resource/payment_methods
    def create
      payment_method = @current_resource.attach_payment_method(payment_method_params[:id], set_as_default: payment_method_params[:set_as_default])

      return render json: payment_method if payment_method

      render json: { success: false }, status: :unprocessable_entity
    end

    private

    def payment_method_params
      params.permit(:id, :set_as_default)
    end
  end
end
