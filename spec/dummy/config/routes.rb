# frozen_string_literal: true

Rails.application.routes.draw do
  mount Flatirons::Saas::Engine => '/flatirons-saas'
end
