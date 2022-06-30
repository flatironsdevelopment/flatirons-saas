# frozen_string_literal: true

shared_context 'subscription_for_users' do
  before(:each) do
    Rails.application.routes.draw do
      devise_for :users
      devise_scope :user do
        subscription_for :users
      end
    end
  end
end
