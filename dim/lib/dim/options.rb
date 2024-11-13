require 'optparse'

require_relative 'globals'
require_relative 'exit_helper'

module Dim
  class Options
    MAX_COUNT = 10

    def self.reset
      OPTIONS[:filter] = ''
      OPTIONS[:title] = 'Requirements - Draft'
      OPTIONS[:folder] = nil
      OPTIONS[:input] = nil
      OPTIONS[:attributes] = nil
      OPTIONS[:config] = nil
      OPTIONS[:allow_missing] = false
      OPTIONS[:output_format] = 'in-place'
      OPTIONS[:type] = nil
      OPTIONS[:no_check_enclosed] = false
      OPTIONS[:silent] = nil
    end
    reset

    def self.parse(args = ARGV)
      op = OptionParser.new do |opts|
        opts.banner = "Usage: dim.rb <#{SUBCOMMANDS.keys.join('|')}> [options]"
        opts.separator "\nGeneral options:"
        opts.on('-h', '--help', 'prints this help') do
          Dim::ExitHelper.exit(code: 0, msg: opts)
        end
        opts.on('-v', '--version', 'prints version') do
          Dim::ExitHelper.exit(code: 0, msg: Dim::Ver.sion)
        end
        opts.on('-l', '--license', 'prints license') do
          Dim::ExitHelper.exit(code: 0, msg: File.read("#{File.dirname(__FILE__)}/../../license.txt"))
        end

        opts.separator "\nFor check, export, stats, format:"
        opts.on('-i FILENAME', '--input FILENAME',  'input file or config') do |i|
          OPTIONS[:input] = i.gsub('\\', '/')
        end
        opts.on('-a FILENAME', '--attributes FILENAME', 'file for custom attributes') do |i|
          OPTIONS[:attributes] = i.gsub('\\', '/')
        end
        opts.on('--allow-missing', 'Missing references are ignored') do |_m|
          OPTIONS[:allow_missing] = true
        end
        opts.on('--no-check-enclosed', 'Skip enclosed file check') do |_|
          OPTIONS[:no_check_enclosed] = true
        end
        opts.on('--silent', 'Silent information log') do |_|
          OPTIONS[:silent] = true
        end

        opts.separator "\nFor export:"
        opts.on('--filter FILTER', 'searches for this string in all fields with enums') do |p|
          OPTIONS[:filter] = p
        end

        opts.separator "\nFor export:"
        opts.on('-o FOLDER', '--output FOLDER', 'output folder') do |p|
          OPTIONS[:folder] = p
        end
        opts.on('-f FORMAT', '--format FORMAT', 'output format',
                "allowed values: #{EXPORTER.keys.join(', ')}") do |p|
          OPTIONS[:type] =
            p
        end

        opts.separator "\nFor format:"
        opts.on('--output-format FORMAT', 'in-place (default): files will be changed if not already formatted correctly',
                'extra: output is written into "<original filename>.formatted"',
                'check-only: no changes to files',
                'stdout: For IDE format support; will work with STDIN/STDOUT; no file input required') do |p|
          OPTIONS[:output_format] = p
        end
      end

      begin
        op.parse!(args)
      rescue OptionParser::InvalidOption => e
        Dim::ExitHelper.exit(code: 1, msg: e.message)
      end

      Dim::ExitHelper.exit(code: 1, msg: op) if args.empty? || !SUBCOMMANDS.keys.include?(args[0])
      OPTIONS[:subcommand] = args[0]

      if OPTIONS[:input].nil? && OPTIONS[:output_format] != 'stdout'
        Dim::ExitHelper.exit(code: 1,
                             msg: 'no input file specified.')
      end

      if OPTIONS[:subcommand] == 'export'
        Dim::ExitHelper.exit(code: 1, msg: 'specify output folder') if OPTIONS[:folder].nil?
        if OPTIONS[:type].nil?
          Dim::ExitHelper.exit(code: 1, msg: "export format not specified, must be one of: #{EXPORTER.keys.join(', ')}")
        end
        unless EXPORTER.keys.include?(OPTIONS[:type])
          Dim::ExitHelper.exit(code: 1, msg: "export format must be one of: #{EXPORTER.keys.join(', ')}")
        end
      end

      if OPTIONS[:output_format] == 'stdout'
        OPTIONS[:silent] = true
        OPTIONS[:no_check_enclosed] = true
        OPTIONS[:allow_missing] = true
      end

      return unless OPTIONS[:subcommand] == 'format'

      OPTIONS[:allow_missing] = true

      return if %w[in-place extra check-only stdout].include?(OPTIONS[:output_format])

      Dim::ExitHelper.exit(code: 1, msg: 'output-format must be in-place, extra or check-only')
    end
  end
end
