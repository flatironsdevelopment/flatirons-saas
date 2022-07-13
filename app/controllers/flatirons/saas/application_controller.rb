# frozen_string_literal: true

module Flatirons
  module Saas
    # All controllers are inherited from here.
    class ApplicationController < ::ActionController::Base
      respond_to :json
      skip_forgery_protection

      rescue_from ActiveRecord::RecordNotFound,       with: :not_found
      rescue_from ActionController::ParameterMissing, with: :missing_param_error
      rescue_from Stripe::InvalidRequestError,        with: :stripe_error

      def not_found(exception)
        render_error exception.message, :not_found
      end

      def missing_param_error(exception)
        render_error exception.message, :unprocessable_entity
      end

      def stripe_error(exception)
        render_error exception.message, :unprocessable_entity
      end

      def render_error(message, status)
        render json: { success: false, message: message }, status: status
      end

      private

      def mapping
        @mapping ||= request.env['flatirons.saas.mapping']
      end

      # Check if there is a signed in user before doing the action.
      #
      # If there is no signed in user, it will raise devise unauthorized error
      def authenticate!
        authenticate_resource_for! mapping[:symbol]
      end

      def authenticate_resource_for!(symbol, opts = {})
        opts[:scope] = symbol
        @current_resource = warden.authenticate!(opts)
        raise_current_resource_mapping_error unless @current_resource.is_a? mapping[:klass]
        @current_resource
      end

      def raise_current_resource_mapping_error
        raise "Authenticated resource type [#{@current_resource.class}] is not the same of mapped [#{mapping[:klass]}],"\
        ' check your subscription_for/devise_for route configuration.'
      end
    end
  end
end
