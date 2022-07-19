# frozen_string_literal: true

require 'rails_helper'
require 'generator_spec'
require 'generators/flatirons/install/install_generator'

module Flatirons::Generators
  RSpec.describe InstallGenerator, type: :generator do
    destination File.expand_path('tmp')

    before(:each) do
      prepare_destination
      allow_any_instance_of(Kernel).to receive(:system).with({ 'RAILS_ENV' => 'test' }, 'rails flatirons_saas:install:migrations').and_return(true)
      Dir.mkdir 'tmp/config'
      File.open('tmp/config/routes.rb', 'w') do |f|
        f.write "Rails.application.routes.draw do\nend"
      end
      run_generator
    end

    describe 'initializer' do
      it 'creates an initializer' do
        assert_file 'config/initializers/flatirons_saas.rb'
      end
      it 'mounts the engine routes' do
        File.open('tmp/config/routes.rb', 'r') do |f|
          routes = f.readlines.join('')
          include_routes = routes.include? 'mount Flatirons::Saas::Engine => \'/flatirons-saas\''
          expect(include_routes).to be true
        end
      end
    end
  end
end
