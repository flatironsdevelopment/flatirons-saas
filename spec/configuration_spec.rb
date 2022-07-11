# frozen_string_literal: true

require 'rails_helper'

describe 'Flatirons::Saas.configure'  do
  it 'should set the stripe api key' do
    stripe_api_key = 'test'
    Flatirons::Saas.configure do |config|
      config.stripe_api_key = stripe_api_key
    end

    expect(Flatirons::Saas.stripe_api_key).to eq(stripe_api_key)
  end
end
