# frozen_string_literal: true

shared_context 'dummy_user_with_subscription' do
  let!(:subscription) { FactoryBot.create(:subscription, subscriptable: current_dummy_user) }
end
