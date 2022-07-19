# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/{resource}/products', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'

  context 'given products' do
    let!(:products) { FactoryBot.create_list(:product, 3) }

    path '/{resource}/products' do
      parameter name: :resource, in: :path, type: :string, description: 'resource name. e.g: products_for: users # resource = users'
      let!(:resource) { 'dummy_users' }

      get('List products') do
        tags 'Product'
        description 'Lists products.'
        consumes 'application/json'
        produces 'application/json'
        security [bearer: []]

        response(200, 'successful') do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     stripe_product_id: { type: :string },
                     name: { type: :string },
                     description: { type: :string, nullable: true },
                     deleted_at: { type: :string, nullable: true },
                     created_at: { type: :string },
                     updated_at: { type: :string }
                   },
                 }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            products = Flatirons::Saas::Product.all.map(&:as_json)
            expect(response.body).to include_json(products)
          end

          after do |example|
            content = example.metadata[:response][:content] || {}
            example_spec = {
              'application/json' => {
                examples: {
                  test_example: {
                    value: JSON.parse(response.body, symbolize_names: true)
                  }
                }
              }
            }
            example.metadata[:response][:content] = content.deep_merge(example_spec)
          end
        end
      end
    end
  end
end
