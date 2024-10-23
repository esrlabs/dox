$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/")

require 'lib/dim/ver'

PKG_FILES = Dir[
  'lib/**/*.rb',
  'license.txt',
  'version.txt'
]

Gem::Specification.new do |s|
  s.name = 'dim-toolkit'
  s.version = Dim::Ver.sion
  s.summary = 'Requirements tooling'
  s.description = 'Creating, maintaining and exporting of requirements.'
  s.homepage = 'https://github.com/esrlabs/dox'
  s.files = PKG_FILES
  s.require_path = 'lib'
  s.author = 'Accenture'
  s.rdoc_options = %w[-x doc]
  s.executables = ['dim']
  s.licenses    = ['Apache-2.0']
  s.required_ruby_version = '>= 2.7'
  s.add_development_dependency 'rspec', '3.10.0'
  s.add_development_dependency 'simplecov', '0.22.0'

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["documentation_uri"] = 'https://esrlabs.github.io/dox/dim'
end
