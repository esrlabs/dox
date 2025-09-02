require_relative '../globals'
require_relative '../exit_helper'
require_relative '../ext/string'
require_relative '../requirement.rb'

module Dim
  class Schema
    SUBCOMMANDS['schema'] = self

    attr_accessor :loader, :final_schema

    def initialize(loader)
      @loader = loader
      @final_schema = {}
    end

    def execute(silent: false)
      self.final_schema = Marshal.load(Marshal.dump(JSON_SCHEMA))
      self.final_schema[:properties].merge!(loader.custom_schema)
      add_defaults_and_enums
      FileUtils.mkdir_p(OPTIONS[:folder]) unless Dir.exist?(OPTIONS[:folder])
      dst = File.join(OPTIONS[:folder], "dim_schema.json")
      File.open(dst, 'w') { |file| file.write(JSON.pretty_generate(final_schema)) }

      puts "JSON schema saved at #{dst}" unless silent
    end

    def add_defaults_and_enums
      Dim::Requirement::SYNTAX.each do |key, data|
        self.final_schema[:properties][key.to_sym][:default] = data[:default] if data[:default] && !data[:default].empty?
        self.final_schema[:properties][key.to_sym][:enum] = data[:allowed] if data[:allowed] && key != "type"
      end
    end
  end
end
