# frozen_string_literal: true

json.extract! product, :id, :name, :stripe_product_id, :description, :deleted_at, :created_at, :updated_at
json.prices product.prices
