# frozen_string_literal: true

require 'stripe_mock'

shared_context 'stripe' do
  before(:all) do
    Flatirons::Saas.configure do |c|
      c.stripe_api_key = 'sk_test'
    end
  end

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:stripe_credit_card) do
    {
      type: 'card',
      card: {
        number: '4242424242424242',
        exp_month: 10,
        exp_year: 2050,
        cvc: '314'
      }
    }
  end
end
