# frozen_string_literal: true

module Flatirons::Saas
  class SubscriptionsController < ApplicationController
    before_action :authenticate!

    # GET /resource/subscriptions
    def index
      render json: @current_resource.subscriptions
    end
  end
end
