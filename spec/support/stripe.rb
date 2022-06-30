# frozen_string_literal: true

shared_context 'stripe' do
  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
end
