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
                   deleted_at: { type: :string }
                 }
               }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(response.body).to include_json([{ id: subscription.id, stripe_subscription_id: subscription.stripe_subscription_id,
                                                   status: subscription.status }])
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          pp example
        end
      end
    end
  end
end
