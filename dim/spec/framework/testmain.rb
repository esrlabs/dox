$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")

module Kernel
  alias __at_exit at_exit
  def at_exit(&block)
    __at_exit do
      exit_status = $ERROR_INFO.status if $ERROR_INFO.is_a?(SystemExit)
      block.call
      exit exit_status if exit_status
    end
  end
end

require 'rspec/core/rake_task'
SPEC_PATTERN = 'spec/**/*_spec.rb'.freeze

namespace :test do
  desc 'Run specs'
  RSpec::Core::RakeTask.new do |t|
    t.pattern = SPEC_PATTERN
    t.rspec_opts = '--dry-run' if $dry_run
  end
end
