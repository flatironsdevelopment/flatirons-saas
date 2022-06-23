# frozen_string_literal: true

module Flatirons
  module Saas
    class FailureApp < Devise::FailureApp
      def respond
        self.status        = 401
        self.content_type  = 'application/json'
        self.response_body = { success: false, error: i18n_message }.to_json
      end
    end
  end
end
