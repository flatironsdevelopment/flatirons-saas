# frozen_string_literal: true

require_dependency 'flatirons/saas/application_controller'

module Flatirons::Saas
  class SubscriptionsController < ApplicationController
    before_action :authenticate!

    def index
      render json: @current_resource.subscriptions
    end

    private

    def authenticate!
      @mapping ||= request.env['flatirons.saas.mapping']
      authenticate_resource_for! @mapping[:symbol]
    end

    def authenticate_resource_for!(symbol, opts = {})
      opts[:scope] = symbol
      @current_resource = warden.authenticate!(opts)
    end
  end
end
