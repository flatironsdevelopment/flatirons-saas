# frozen_string_literal: true

module Flatirons::Saas
  module Configuration
    mattr_accessor :stripe_api_key
    def configure
      yield self
    end
  end
end
