# frozen_string_literal: true

require 'rails_helper'

describe 'RouteSet', type: :routing  do
  context 'users' do
    include_context 'with_user_model'

    after(:each) do
      Devise.mappings.delete(:user) if defined?(Devise)
      Flatirons::Saas::Rails::Subscription.mappings.delete(:user)
      Flatirons::Saas::Rails::Product.mappings.delete(:user)
    end

    context 'devise is not available' do
      it 'should raise devise is not available' do
        User.subscriptable
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
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            devise_for :users, class_name: 'DummyUser'
            subscription_for :users
          end
        end
          .to raise_error 'Devise resource type [DummyUser] is not the same of subscription_for [User],'\
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

    context 'user is not subscriptable' do
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

    context 'user is subscriptable' do
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

    describe '#products_for' do
      with_model :Product do
        table do |t|
          t.string :name
          t.timestamps null: false
        end

        model do
          productable
        end
      end

      it 'should raise devise is not available' do
        without_const('Devise') do
          expect do
            routes = ActionDispatch::Routing::RouteSet.new
            routes.draw do
              products_for :users
            end
          end
            .to raise_error 'Devise is not available, please include devise gem to get work.'
        end
      end

      it 'should raise devise resource type error' do
        User.productable
        expect do
          routes = ActionDispatch::Routing::RouteSet.new
          routes.draw do
            devise_for :users, class_name: 'DummyUser'
            products_for :users
          end
        end
          .to raise_error 'Devise resource type [DummyUser] is not the same of products_for [User],'\
          ' check your products_for/devise_for route configuration.'
      end

      context 'devise_for :users is not configured' do
        it 'should raise devise for :users not found' do
          User.productable
          expect do
            routes = ActionDispatch::Routing::RouteSet.new
            routes.draw do
              products_for :users
            end
          end
            .to raise_error 'Devise for :users not found, please check your products_for/devise_for route configuration.'
        end
      end

      context 'product is not productable' do
        with_model :SomeProduct do
          table do |t|
            t.string :name
            t.timestamps null: false
          end

          model do
          end
        end
        it 'should raise does not respond to \'productable\' method' do
          expect do
            routes = ActionDispatch::Routing::RouteSet.new
            routes.draw do
              devise_for :users
              products_for :users, productable_class_name: 'SomeProduct'
            end
          end
            .to raise_error 'SomeProduct does not respond to \'productable\' method.'
        end
      end

      context 'product is productable' do
        it 'should not raise error' do
          expect do
            routes = ActionDispatch::Routing::RouteSet.new
            routes.draw do
              devise_for :users
              products_for :users
            end
          end
            .not_to raise_error
        end

        context 'routing' do
          before(:each) { User.productable }

          routes do
            route_set = ActionDispatch::Routing::RouteSet.new
            route_set.draw do
              devise_for :users
              products_for :users
            end
            route_set
          end

          it 'should route to index' do
            expect(get: '/users/products')
              .to route_to(controller: 'flatirons/saas/products', action: 'index')
          end
        end
      end
    end
  end
end
