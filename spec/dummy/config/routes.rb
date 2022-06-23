# frozen_string_literal: true

Rails.application.routes.draw do
  mount Flatirons::Saas::Engine => '/flatirons-saas'
  devise_for :dummy_users
  devise_scope :dummy_user do
    subscription_for :dummy_users
  end
end
