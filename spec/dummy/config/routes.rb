# frozen_string_literal: true

Rails.application.routes.draw do
  mount Flatirons::Saas::Engine => '/flatirons-saas'
  devise_for :dummy_users
  subscription_for :dummy_users, path: 'session/me', class_name: :DummyUser
  subscription_for :dummy_users
end
