# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe '/dummy_users/subscriptions', type: :request do
  include_context 'dummy_user'
  include_context 'dummy_user_is_authenticated'
  include_context 'dummy_user_with_subscription'

  path '/dummy_users/subscriptions' do
    get('List dummy user subscriptions') do
      tags 'Subscription'
      description 'Lists current user subscriptions.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   stripe_subscription_id: { type: :string },
                   subscriptable_type: { type: :string },
                   subscriptable_id: { type: :integer },
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
