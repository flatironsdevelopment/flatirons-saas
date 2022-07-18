# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/dummy_users/subscriptions', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'

  let!(:stripe_product) { Stripe::Product.create({ name: 'Beer' }) }
  let!(:stripe_price) { Stripe::Price.create({  unit_amount: 4000, currency: 'usd', product: stripe_product.id }) }
  let!(:product) { Flatirons::Saas::Product.create({ name: 'Beer', stripe_product_id: stripe_product.id }) }

  path '/dummy_users/subscriptions' do
    post('Create a new subscription') do
      tags 'Subscription'
      description 'Create a subscription.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]
      parameter name: :subscription_params, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer },
          stripe_price_id: { type: :string }
        },
        require: %i[product_id stripe_price_id]
      }

      context 'when product does not exist' do
        response(404, 'not found') do
          let!(:subscription_params) { { product_id: 10, stripe_price_id: nil } }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
            error = JSON.parse(response.body)
            expect(error['message']).to eq('Product not found')
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

      context 'when product exists' do
        context 'when price is nil' do
          response(422, 'unprocessable_entity') do
            let!(:product) { Flatirons::Saas::Product.create(name: 'Flatirons') }
            let!(:subscription_params) { { product_id: product.id, stripe_price_id: nil } }

            run_test! do |response|
              expect(response).to have_http_status(:unprocessable_entity)
              error = JSON.parse(response.body)
              expect(error['errors']).to eq('Stripe price can\'t be blank')
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

        context 'given a valid price' do
          response(200, 'successful') do
            let!(:subscription_params) { { product_id: product.id, stripe_price_id: stripe_price.id } }

            run_test! do |response|
              expect(response).to have_http_status(:ok)
              subscription = JSON.parse(response.body)
              expect(subscription['id']).to_not be_nil
              expect(subscription['stripe_subscription_id']).to_not be_nil
              expect(subscription['stripe_price_id']).to eq stripe_price.id
              expect(subscription['status']).to eq 'active'
              expect(subscription['subscriptable_type']).to eq 'DummyUser'
              expect(subscription['subscriptable_id']).to eq current_dummy_user.id
              expect(subscription['product_type']).to eq 'Flatirons::Saas::Product'
              expect(subscription['product_id']).to eq product.id
              expect(subscription['deleted_at']).to be_nil
              expect(subscription['canceled_at']).to be_nil
              expect(subscription['created_at']).to_not be_nil
              expect(subscription['updated_at']).to_not be_nil
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

    get('List dummy user subscriptions') do
      tags 'Subscription'
      description 'Lists current user subscriptions.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      context 'given one subscription' do
        let!(:subscription) { FactoryBot.create(:subscription, subscriptable: current_dummy_user, product: product, stripe_price_id: stripe_price.id) }

        response(200, 'successful') do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     stripe_subscription_id: { type: :string },
                     stripe_price_id: { type: :string },
                     subscriptable_type: { type: :string },
                     subscriptable_id: { type: :integer },
                     product_type: { type: :string },
                     product_id: { type: :integer },
                     status: { type: :string },
                     deleted_at: {  type: :string, nullable: true },
                     canceled_at: { type: :string, nullable: true }
                   },
                 }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.body).to include_json([{ id: subscription.id, stripe_subscription_id: subscription.stripe_subscription_id,
                                                     status: subscription.status }])
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
