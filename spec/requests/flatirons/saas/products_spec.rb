# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/dummy_users/products', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'

  with_model 'Flatirons::Saas::Product' do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      productable
    end
  end

  it 'lists all products' do
    FactoryBot.create_list(:product, 3)
    product_names = Flatirons::Saas::Product.all.pluck(:name).sort

    get '/dummy_users/products'
    payload = JSON.parse(response.body)
    expect(response.status).to eq 200
    expect(payload.size).to eq 3
    request_names = payload.map { |product| product['name'] }.sort
    expect(request_names == product_names).to eq(true)
  end
end
