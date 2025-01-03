# frozen_string_literal: true

require_relative "lib/dim_to_rst/version"

Gem::Specification.new do |spec|
  spec.name = "dim_to_rst"
  spec.version = DimToRst::VERSION
  spec.authors = ["Accenture"]

  spec.summary = "An example of a custom exporter gem for dim."
  spec.description = "Exports requirements written in dim to plain RST source."
  spec.homepage = "https://github.com/esrlabs/dox/tree/master/dim/examples/scripting/dim_to_rst"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/esrlabs/dox/tree/master/dim/examples/scripting/dim_to_rst/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[exe/ lib/ CHANGELOG.md README.md])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7"
  spec.add_dependency "dim-toolkit", '>= 2.1.1'
end
