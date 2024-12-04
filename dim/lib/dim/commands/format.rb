require 'fileutils'

require_relative '../globals'

module Dim
  class Format
    SUBCOMMANDS['format'] = self
    TARGET_WIDTH = 120
    TARGET_WIDTH_ONE_LINER = 150
    WIDTH_MIN = 50 # used when ID in one-liner or language-attr is very long

    def initialize(loader)
      @loader = loader
    end

    def short_type(type)
      return "h#{type[8..]}" if /\Aheading_(\d+)\z/ === type

      'info' # type == "information"
    end

    def create_string_array(val, line_width, line_width_first)
      input = val.strip
      return ['|'] + input.split("\n") if input.include?("\n")

      if "#,[]{}&*!|>\)\"%@`'?:-".include?(input[0]) || input =~ /(:(\s|\Z)|\s#)/ || (input.length > line_width_first && input =~ /\s\s/)
        return ['|', input] if input.length <= line_width_first

        res = ['>']
      else
        res = []
      end
      until input.empty?
        width = (res.empty? ? line_width_first : line_width)
        if input.length <= width
          res << input
          break
        end
        pos = input[0, width + 2].rindex(/ \w/)
        if pos
          res << input[0, pos]
          input = input[pos + 1..]
        else
          pos = input.index(/ \w/)
          if pos
            res << input[0, pos]
            input = input[pos + 1..]
          else
            res << input
            break
          end
        end
      end
      res
    end

    def dump(attr, val, shift, target_width = TARGET_WIDTH)
      shift_first = [shift - attr.length, 0].max

      line_width = [target_width - shift, WIDTH_MIN].max
      line_width_first = [target_width - [shift, attr.length].max, WIDTH_MIN].max

      array = create_string_array(val, line_width, line_width_first)
      array[0] = attr + ' ' * shift_first + array[0]
      (1..array.length - 1).each do |i|
        array[i] = ' ' * shift + array[i]
      end
      array
    end

    def format_file(data)
      io = StringIO.new

      io.puts "document: #{data['document']}\n\n"

      if data.key?('metadata') && !data['metadata'].empty?
        io.puts dump('metadata: ', data['metadata'], 10)
        io.puts "\n"
      end

      data.each do |id, req|
        next if %w[enclosed document].include? id

        # do not write default values
        next unless req.is_a?(Hash)

        req.delete_if { |_key, value| value.nil? }

        %w[tags verification_methods refs].each do |e|
          req[e] = req[e].cleanUniqString if req.key?(e) && req[e].is_a?(String)
        end

        # use oneliner style for headings and information if reasonable
        if req.keys.length == 2 &&
           %w[type text].all? { |e| req.key?(e) } &&
           (req['type'] =~ /\Aheading_\d+\Z/ ||
            req['type'] =~ /\Ainformation\Z/)
          stripped = req['text'].strip
          unless stripped.include?("\n")
            one_liner = "#{short_type(req['type'])} #{req['text']}"
            str = dump("#{id}: ", one_liner, Requirement::SYNTAX['text'][:format_shift], TARGET_WIDTH_ONE_LINER)
            if str.length == 1
              io.puts str
              io.puts "\n"
              next
            end
          end
        end

        io.puts "#{id}:"
        @loader.all_attributes.each_key do |k|
          next unless req.key?(k)

          if req[k] && req[k].empty? || req[k].nil?
            io.puts "  #{k}:"
            next
          end
          shift = [@loader.all_attributes[k][:format_shift], k.length + 4].max
          case @loader.all_attributes[k][:format_style]
          when :single
            shift_str = ' ' * [shift - (k.length + 4), 0].max
            io.puts "  #{k}: #{shift_str}#{req[k].strip}"
          when :multi
            shift_str = ' ' * [shift - (k.length + 4), 0].max
            io.puts "  #{k}: #{shift_str}#{req[k].cleanUniqString}"
          when :list
            io.puts dump("  #{k}: ", req[k].cleanUniqString, shift)
          when :text
            io.puts dump("  #{k}: ", req[k], shift)
          when :split
            arr = req[k].cleanUniqArray

            if arr.length == 1
              io.puts "  #{k}: #{shift_str}#{arr[0]}"
            else
              io.puts "  #{k}: #{shift_str}>"
              shift_str = ' ' * shift
              arr.each_with_index do |a, i|
                io.puts "#{shift_str}#{a}#{i < arr.length - 1 ? ',' : ''}"
              end
            end
          else
            Dim::ExitHelper.exit(code: 1, msg: 'Invalid format style')
          end
        end

        io.puts "\n"
      end

      if data.key?('enclosed')
        a = Array(data['enclosed'])
        if a.length == 1
          io.puts "enclosed: #{a[0]}\n\n"
        else
          io.puts "enclosed:\n"
          Array(data['enclosed']).each do |e|
            io.puts "  - #{e}"
          end
          io.puts "\n"
        end
      end

      io.truncate(io.length - 1) # do not print two line breaks at the end

      io
    end

    def execute(silent: true)
      puts OPTIONS[:output_format] == 'check-only' ? 'Checking format...' : 'Formatting...' unless silent

      incorrect_files = []
      @loader.original_data.each do |filename, data|
        formatted_data = format_file(data).string
        if OPTIONS[:output_format] == 'check-only'
          original_data = File.read(filename).universal_newline
          incorrect_files << filename if original_data != formatted_data
        elsif OPTIONS[:output_format] == 'stdout'
          puts formatted_data
          next
        else
          output_filename = OPTIONS[:output_format] == 'extra' ? "#{filename}.formatted" : filename
          File.write(output_filename, formatted_data)
        end
      end

      unless incorrect_files.empty?
        io = StringIO.new
        io.puts 'The following files are not formatted correctly:'
        io.puts(incorrect_files.map { |f| "- #{f}" })
        Dim::ExitHelper.exit(code: 1, msg: io.string)
      end

      puts 'Done.' unless silent
    end
  end
end
