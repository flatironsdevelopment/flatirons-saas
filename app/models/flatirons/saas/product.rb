# frozen_string_literal: true

module Flatirons::Saas
  # Product Active Record
  #
  # == Examples
  #
  #   # get all Products
  #   Flatirons::Saas:Product.all
  #
  class Product < ApplicationRecord
    productable

    validates :name, presence: true
  end
end
