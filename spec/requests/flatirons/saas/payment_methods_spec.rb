# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/dummy_users/payment_methods', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'
  include_context 'dummy_user_with_subscription'
  include_context 'dummy_user_with_payment_methods'

  path '/dummy_users/payment_methods' do
    get('List dummy user payment methods') do
      tags 'Subscription'
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
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end
  end
end
