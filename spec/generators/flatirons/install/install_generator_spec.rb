# frozen_string_literal: true

require 'rails_helper'
require 'generator_spec'
require 'generators/flatirons/install/install_generator'

module Flatirons::Generators
  RSpec.describe InstallGenerator, type: :generator do
    destination File.expand_path('tmp')

    before(:all) do
      prepare_destination
      run_generator
    end

    describe 'initializer' do
      it 'creates an initializer' do
        assert_file 'config/initializers/flatirons_saas.rb'
      end
    end
  end
end
