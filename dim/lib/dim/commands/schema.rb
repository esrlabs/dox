require_relative '../globals'
require_relative '../exit_helper'
require_relative '../ext/string'

module Dim
  class Schema
    SUBCOMMANDS['schema'] = self

    attr_reader :loader

    def initialize(loader)
      @loader = loader
    end

    def execute(silent: false)
      final_schema = Marshal.load(Marshal.dump(JSON_SCHEMA))
      final_schema[:properties].merge!(loader.custom_schema)
      FileUtils.mkdir_p(OPTIONS[:folder]) unless Dir.exist?(OPTIONS[:folder])
      dst = File.join(OPTIONS[:folder], "dim_schema.json")
      File.open(dst, 'w') { |file| file.write(JSON.pretty_generate(final_schema)) }

      puts "JSON schema saved at #{dst}" unless silent
    end
  end
end
