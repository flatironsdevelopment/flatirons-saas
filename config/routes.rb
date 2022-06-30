# frozen_string_literal: true

Flatirons::Saas::Engine.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
