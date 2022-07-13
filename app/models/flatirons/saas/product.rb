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

    #
    # Define stripe product extra attributes
    #
    # @return [Hash]
    #
    def stripe_product_attrs
      { description: description }
    end
  end
end
