# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/dummy_users/payment_methods', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'
  include_context 'dummy_user_with_subscription'
  include_context 'dummy_user_with_payment_methods'

  path '/dummy_users/payment_methods' do
    get('List payment methods') do
      tags 'Payment Methods'
      description 'Lists current user payment methods.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   object: { type: :string },
                   billing_details: { type: :object },
                   card: { type: :object },
                   created: { type: :integer },
                   customer: { type: :string },
                   livemode: { type: :boolean },
                   metadata: { type: :object },
                   type: { type: :string }
                 },
               }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.body).to include_json([{ id: first_payment_method_id }, { id: second_payment_method_id }])
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

    post('Attach payment method') do
      tags 'Payment Methods'
      description 'Lists current user payment methods.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]
      parameter name: :payment_method_params, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string },
          set_as_default: { type: :boolean, nullable: true }
        },
        require: [:id]
      }

      let!(:new_payment_method) { Stripe::PaymentMethod.create(stripe_credit_card) }

      response(200, 'successful') do
        let(:payment_method_params) { { id: new_payment_method.id } }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.body).to include_json({ id: new_payment_method.id })
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

      response(422, 'unprocessable_entity') do
        let(:payment_method_params) { { id: nil } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to_not include_json({ id: new_payment_method.id })
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
