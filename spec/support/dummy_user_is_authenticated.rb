# frozen_string_literal: true

shared_context 'dummy_user_is_authenticated' do
  before(:each) do
    sign_in current_dummy_user, scope: :dummy_user
  end
end
