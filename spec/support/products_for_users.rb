# frozen_string_literal: true

shared_context 'products_for_users' do
  before(:each) do
    Rails.application.routes.draw do
      devise_for :dummy_users
      devise_scope :dummy_user do
        products_for :dummy_users, resource_class_name: 'Flatirons::Saas::Product'
      end
    end
  end
end
