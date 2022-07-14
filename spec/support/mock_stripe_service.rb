# frozen_string_literal: true

def mock_stripe_service
  service = instance_double(Flatirons::Saas::Services::StripeService)
  allow(Flatirons::Saas::Services::StripeService).to receive(:new).and_return(service)
  service
end
