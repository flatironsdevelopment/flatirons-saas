# frozen_string_literal: true

module Flatirons
  module Saas
    # All controllers are inherited from here.
    class ApplicationController < ::ActionController::Base
      respond_to :json
      skip_forgery_protection

      rescue_from ActiveRecord::RecordNotFound,       with: :not_found
      rescue_from ActionController::ParameterMissing, with: :missing_param_error

      def not_found(exception)
        render_error exception.message, :not_found
      end

      def missing_param_error(exception)
        render_error exception.message, :unprocessable_entity
      end

      def render_error(message, status)
        render json: message, status: status
      end
    end
  end
end
