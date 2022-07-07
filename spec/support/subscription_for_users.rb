# frozen_string_literal: true

shared_context 'subscription_for_users' do
  before(:each) do
    Rails.application.routes.draw do
      devise_for :dummy_users
      devise_scope :dummy_user do
        subscription_for :dummy_users
      end
    end
  end
end
