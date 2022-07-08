# frozen_string_literal: true

module Flatirons
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Flatirons saas install, sets up engime mount route config, copy default migrations, create flatirons_saas initializer.'

      def install
        copy_file 'flatirons_saas.erb', 'config/initializers/flatirons_saas.rb'
        route "mount Flatirons::Saas::Engine => '/flatirons-saas'"
        rake 'flatirons_saas:install:migrations'
      end
    end
  end
end
