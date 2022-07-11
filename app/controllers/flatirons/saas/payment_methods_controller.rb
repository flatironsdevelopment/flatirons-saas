# frozen_string_literal: true

module Flatirons::Saas
  class PaymentMethodsController < ApplicationController
    before_action :authenticate!

    # GET /resource/payment_methods
    def index
      render json: @current_resource.payment_methods
    end
  end
end
