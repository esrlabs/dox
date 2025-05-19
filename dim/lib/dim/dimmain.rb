$stdout.sync = true

require 'yaml'
require 'stringio'

require_relative 'globals'
require_relative 'exit_helper'
require_relative 'ext/string'
require_relative 'loader'
require_relative 'ver'
require_relative 'requirement'
require_relative 'commands/stats'
require_relative 'commands/check'
require_relative 'commands/export'
require_relative 'commands/format'
require_relative 'options'

module Dim
  def self.main(args = ARGV)
    Dim::Options.parse(args)
    loader = Dim::Loader.new
    loader.load(file: OPTIONS[:input],
                attributes_file: OPTIONS[:attributes],
                allow_missing: OPTIONS[:allow_missing],
                no_check_enclosed: OPTIONS[:no_check_enclosed] || false,
                silent: OPTIONS[:silent] || false)
    SUBCOMMANDS[OPTIONS[:subcommand]].new(loader).execute(silent: OPTIONS[:silent] || false)
  end
end
