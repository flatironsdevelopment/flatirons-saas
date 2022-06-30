# frozen_string_literal: true

Flatirons::Saas.configure do |config|
  # Set stripe api key
  #
  # Example:
  config.stripe_api_key = ENV['STRIPE_API_KEY']
end
