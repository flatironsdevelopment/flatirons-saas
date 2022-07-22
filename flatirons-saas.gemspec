# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'flatirons/saas/version'

Gem::Specification.new do |spec|
  spec.name        = 'flatirons-saas'
  spec.version     = Flatirons::Saas::VERSION
  spec.authors     = ['Gabriel Siqueira']
  spec.email       = ['gabrielleandrojunior@live.com']
  spec.homepage    = 'https://flatironsdevelopment.com'
  spec.summary     = 'Flatirons::Saas.'
  spec.description = 'Flatirons::Saas.'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/flatironsdevelopment/flatirons-saas'
  spec.metadata['changelog_uri'] = 'https://github.com/flatironsdevelopment/flatirons-saas'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib,swagger}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.7'
  spec.add_dependency 'money-rails', '~> 1.12'
  spec.add_dependency 'pg', '~> 1.1'
  spec.add_dependency 'rails', '~>7.0', '<= 7.0.0'
  spec.add_development_dependency 'factory_bot_rails', '~> 6.2'
  spec.add_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-rails', '~> 5.1'
  spec.add_development_dependency 'rubocop', '~> 1.30'
  spec.add_development_dependency 'rubocop-rails', '~> 2.15'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.11'
  spec.add_development_dependency 'shoulda-matchers', '~> 5.1'
  spec.add_development_dependency 'solargraph', '~> 0.45'
  spec.add_dependency 'stripe', '~> 5.55'
  spec.add_development_dependency 'faker', '~> 2.21'
  spec.add_development_dependency 'figaro', '~> 1.2'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-cobertura', '~> 2.1'
  spec.add_development_dependency 'with_model', '~> 2.1'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_dependency 'devise', '~> 4.8'
  spec.add_development_dependency 'rspec-json_expectations', '~> 2.2'
  spec.add_dependency 'rswag', '~> 2.5'
  spec.add_development_dependency  'byebug', '~> 9.0', '>= 9.0.5'
  spec.add_development_dependency 'generator_spec', '~> 0.9'
  spec.add_development_dependency 'rswag-specs', '~> 2.5'
  spec.add_dependency 'jbuilder', '~> 2.11'
end
