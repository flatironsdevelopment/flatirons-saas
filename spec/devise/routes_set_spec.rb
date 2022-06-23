# frozen_string_literal: true

require 'rails_helper'

describe 'RouteSet', type: :routing  do
  context 'users' do
    include_context 'with_user_model'

    context 'user is not subscritable' do
      it 'should railse does not respond to \'subscriptable\' method' do
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            subscription_for :users
          end
        end
          .to raise_error 'User does not respond to \'subscriptable\' method.'
      end
    end

    context 'user is subscritable' do
      it 'should not railse error' do
        User.subscriptable
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            subscription_for :users
          end
        end
          .not_to raise_error
      end

      context 'routing' do
        before(:each) { User.subscriptable }

        routes do
          route_set = ActionDispatch::Routing::RouteSet.new
          route_set.draw do
            subscription_for :users
          end
          route_set
        end

        it 'should route to index' do
          expect(get: '/users/subscriptions')
            .to route_to(controller: 'flatirons/saas/subscriptions', action: 'index')
        end
      end
    end
  end
end
