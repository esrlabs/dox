require 'json'
require 'fileutils'

begin
  gem 'simplecov', '=0.22.0'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    enable_coverage :branch
  end
rescue Exception
  # Ignored
end

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'dim/dimmain'
require_relative './output'

TEST_OUTPUT_DIR = 'spec/test_output'.freeze
TEST_INPUT_DIR  = 'spec/test_input'.freeze

module Dim
  module Test
    def self.main(args_str)
      args = args_str.split(/\s(?=(?:[^"]|"[^"]*")*$)/).map { |s| s.strip.delete('\"') }
      begin
        $test_exception = nil
        Dim.main(args)
      rescue Exception => e
        $test_exception = e
      end
    end

    def self.execute(&block)
      $test_exception = nil
      yield block
    rescue Exception => e
      $test_exception = e
    end

    def self.clean_testdata
      Options.reset
      FileUtils.rm_rf(TEST_OUTPUT_DIR)
      Dir.glob("#{TEST_INPUT_DIR}/**/*.dim.formatted").each do |f|
        FileUtils.rm_f(f)
      end
    end
  end
end

class Summary
  def dump_summary(res)
    table = { '' => [] }
    res.examples.each do |e|
      e.metadata.fetch(:doc_refs, ['']).each do |id|
        next if id == 'IGNORE'

        table[id] ||= []
        table[id] << {
          'location' => e.location.gsub('./', ''),
          'description' => e.full_description
        }
      end
    end
    folder = "#{File.dirname(__FILE__)}/../../documentation/source/pages/requirements-generated"
    FileUtils.mkdir_p(folder)
    File.write("#{folder}/mapping.json", JSON.pretty_generate(table))
  end
end

RSpec.configure do |config|
  config.reporter.register_listener(Summary.new, :dump_summary)

  config.before(:all) do |the_test|
    $stdout.write "Testing #{the_test.class}:\n"
  end

  config.after(:all) do |_the_test|
    puts "\nDONE"
  end

  $org_keys = Dim::Requirement::SYNTAX.keys
  config.before(:each) do |_the_test|
    Dim::Test.clean_testdata
    Dim::Requirement::SYNTAX.delete_if { |k| !$org_keys.include? k }
    Dim::Requirement.instance_methods.each do |k|
      Dim::Requirement.remove_method(k) if %w[text_ verification_criteria_ comment_].any? { |lang| k.start_with?(lang) }
    end

    $stdout_backup = Thread.current[:stdout]
    @test_stdout = ''
    Thread.current[:stdout] = StringIO.open(@test_stdout, 'w+')

    $stderr_backup = Thread.current[:stderr]
    @test_stderr = ''
    Thread.current[:stderr] = StringIO.open(@test_stderr, 'w+')
  end

  config.after(:each) do |the_test|
    Thread.current[:stdout] = $stdout_backup
    Thread.current[:stderr] = $stderr_backup

    Dim::ExitHelper.reset_exit_code

    Dim::Test.clean_testdata

    unless the_test.instance_variable_get(:@exception).nil?
      puts @test_stdout
      puts @test_stderr
    end
  end
end
