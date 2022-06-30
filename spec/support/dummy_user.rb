# frozen_string_literal: true

shared_context 'dummy_user' do
  let!(:current_dummy_user) { DummyUser.create(email: 'flatirons-saas@flatironsdevelopment.com', password: 'Password#12345') }
end
