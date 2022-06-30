# frozen_string_literal: true

module Flatirons
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Flatirons saas install.'

      def copy_initializer
        copy_file 'flatirons_saas.erb', 'config/initializers/flatirons_saas.rb'
      end
    end
  end
end
