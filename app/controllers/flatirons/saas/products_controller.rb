# frozen_string_literal: true

module Flatirons::Saas
  class ProductsController < ApplicationController
    before_action :authenticate!

    # GET /resource/products
    def index
      render json: Product.all
    end
  end
end
