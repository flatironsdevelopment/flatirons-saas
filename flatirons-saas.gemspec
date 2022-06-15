# frozen_string_literal: true

require_relative 'lib/flatirons/saas/version'

Gem::Specification.new do |spec|
  spec.name        = 'flatirons-saas'
  spec.version     = Flatirons::Saas::VERSION
  spec.authors     = ['Gabriel Siqueira']
  spec.email       = ['gabrielleandrojunior@live.com']
  spec.homepage    = 'https://flatironsdevelopment.com'
  spec.summary     = 'Summary of Flatirons::Saas.'
  spec.description = 'Description of Flatirons::Saas.'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/flatironsdevelopment/flatirons-saas'
  spec.metadata['changelog_uri'] = 'https://github.com/flatironsdevelopment/flatirons-saas'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.required_ruby_version = '>= 2.7'
  spec.add_dependency 'rails', '>= 7.0.3'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'stripe'
end
