# frozen_string_literal: true

Rails.application.routes.draw do
  mount Flatirons::Saas::Engine => '/flatirons-saas'
  devise_for :dummy_users
  devise_scope :dummy_user do
    products_for :dummy_users
  end
  subscription_for :dummy_users, path: 'session/me', class_name: :DummyUser
  subscription_for :dummy_users
end
