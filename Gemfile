# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in flatirons-saas.gemspec.
gemspec

ruby '2.7.4'

gem 'sprockets-rails'

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
group :test do
  gem 'stripe-ruby-mock',
      require: 'stripe_mock',
      git: 'https://github.com/rebelidealist/stripe-ruby-mock.git',
      branch: 'master'
  gem 'webdrivers'
end
