# frozen_string_literal: true

require 'rails_helper'

describe 'RouteSet', type: :routing  do
  context 'users' do
    include_context 'with_user_model'

    after(:each) do
      Devise.mappings.delete(:user) if defined?(Devise)
      Flatirons::Saas::Rails::Subscription.mappings.delete(:user)
    end

    context 'devise is not availabe' do
      it 'should raise devise is not available' do
        without_const('Devise') do
          expect do
            routes = ActionDispatch::Routing::RouteSet.new
            routes.draw do
              subscription_for :users
            end
          end
            .to raise_error 'Devise is not available, please include devise gem to get work.'
        end
      end
    end

    context 'devise is wrong configured with subscription_for' do
      it 'should raise devise resource type error' do
        User.subscriptable
        user_devise = double
        allow(Devise.mappings).to receive(:[]).and_return user_devise
        allow(user_devise).to receive(:class_name).and_return 'OtherClassName'
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            devise_for :users
            subscription_for :users
          end
        end
          .to raise_error 'Devise resource type [OtherClassName] is not the same of subscription_for [User],'\
          ' check your subscription_for/devise_for route configuration.'
      end
    end

    context 'devise_for :users is not configured' do
      it 'should raise devise for :users not found' do
        User.subscriptable
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            subscription_for :users
          end
        end
          .to raise_error 'Devise for :users not found, please check your subscription_for/devise_for route configuration.'
      end
    end

    context 'user is not subscritable' do
      it 'should raise does not respond to \'subscriptable\' method' do
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            devise_for :users
            subscription_for :users
          end
        end
          .to raise_error 'User does not respond to \'subscriptable\' method.'
      end
    end

    context 'user is subscritable' do
      it 'should not raise error' do
        User.subscriptable
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            devise_for :users
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
            devise_for :users
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
