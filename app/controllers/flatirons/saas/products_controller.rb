# frozen_string_literal: true

module Flatirons::Saas
  class ProductsController < ApplicationController
    before_action :authenticate!

    # GET /resource/products
    def index
      klass = mapping[:productable_klass]
      @products = klass.all
    end
  end
end
