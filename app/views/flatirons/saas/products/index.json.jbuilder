# frozen_string_literal: true

json.array! @products do |product|
  json.partial! '/flatirons/saas/products/product_info', product: product
end
