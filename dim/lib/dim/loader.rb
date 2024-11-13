require 'yaml'
require 'pathname'

require_relative 'encoding'
require_relative 'globals'
require_relative 'ext/psych'
require_relative 'requirement'
require_relative 'consistency'
require_relative 'exit_helper'
require_relative 'helpers/attribute_helper'
require_relative 'helpers/file_helper'

using Dim::Refinements

module Dim
  class Loader
    include Helpers::AttributeHelper

    attr_reader :requirements, :config, :property_table, :properties, :original_data, :module_data, :metadata,
                :dim_file, :all_attributes, :custom_attributes

    # YAML standard:
    # invalid C0 control characters: 0x00 - 0x1F (except TAB 0x09, LF 0x0A and CR 0x0D)
    # invalid control character DEL 0x7F
    # invalid C1 control characters: 0x80 - 0x9F (except NEL 0x85)
    #
    # in addition NEL will be also replaced which seems to be misused in CRS documents
    @@invalid_ccs = {
      "\x00" => '[NUL]', "\x01" => '[SOH]', "\x02" => '[STX]', "\x03" => '[ETX]',
      "\x04" => '[EOT]', "\x05" => '[ENQ]', "\x06" => '[ACK]', "\x07" => '[BEL]',
      "\x08" => '[BS]',                                        "\x0B" => '[VT]',
      "\x0C" => '[FF]',                     "\x0E" => '[SO]',  "\x0F" => '[SI]',
      "\x10" => '[DLE]', "\x11" => '[DC1]', "\x12" => '[DC2]', "\x13" => '[DC3]',
      "\x14" => '[DC4]', "\x15" => '[NAK]', "\x16" => '[SYN]', "\x17" => '[ETB]',
      "\x18" => '[CAN]', "\x19" => '[EM]',  "\x1A" => '[SUB]', "\x1B" => '[ESC]',
      "\x1C" => '[FS]',  "\x1D" => '[GS]',  "\x1E" => '[RS]',  "\x1F" => '[US]',
      "\x7F" => '[DEL]',
      "\u0080" => '[PAD]', "\u0081" => '[HOP]', "\u0082" => '[BPH]', "\u0083" => '[NBH]',
      "\u0084" => '[IND]', "\u0085" => '[NEL]', "\u0086" => '[SSA]', "\u0087" => '[ESA]',
      "\u0088" => '[HTS]', "\u0089" => '[HTJ]', "\u008A" => '[VTS]', "\u008B" => '[PLD]',
      "\u008C" => '[PLU]', "\u008D" => '[RI]',  "\u008E" => '[SS2]', "\u008F" => '[SS3]',
      "\u0090" => '[DCS]', "\u0091" => '[PU1]', "\u0092" => '[PU2]', "\u0093" => '[STS]',
      "\u0094" => '[CCH]', "\u0095" => '[MW]',  "\u0096" => '[SPA]', "\u0097" => '[EPA]',
      "\u0098" => '[SOS]', "\u0099" => '[SGCI]', "\u009A" => '[SCI]', "\u009B" => '[CSI]',
      "\u009C" => '[ST]',  "\u009D" => '[OSC]', "\u009E" => '[PM]', "\u009F" => '[APC]'
    }

    def initialize
      @requirements = {}
      @module_data = {}
      @metadata = {}
      @config = {}
      @properties = {}
      @property_table = {}
      @original_data = {}
      @all_attributes = Requirement::SYNTAX.dup
      @custom_attributes = {}
    end

    def filter(str)
      @requirements.keep_if { |_id, r| r.filter(str) }
    end

    def load(file: nil, attributes_file: nil, allow_missing: false, no_check_enclosed: false, silent: true,
             input_filenames: [])
      ::Psych::Nodes::Scalar.add_patch
      ::Psych::Visitors::ToRuby.add_patch

      input_filenames = *input_filenames
      # If output format is vim then we do not need to read the file,
      # content will be read from the stdin and printed out to stdout. This is to enhance the
      # formatting in the vim.
      unless OPTIONS[:output_format] == 'stdout'
        if input_filenames.length.positive? && file
          Dim::ExitHelper.exit(code: 1, msg: 'use either file or input_filenames argument (deprecated) for load method')
        end
        if input_filenames.length > 1
          Dim::ExitHelper.exit(code: 1,
                               msg: 'input_filenames argument (deprecated) of load method must have at maximum one entry')
        end
        file = input_filenames[0] if input_filenames.length == 1
        unless file
          Dim::ExitHelper.exit(code: 1,
                               msg: 'neither file nor input_filenames argument (deprecated) argument specified for load method')
        end
      end

      unless silent
        if allow_missing && OPTIONS[:subcommand] != 'format'
          puts "Warning: Using 'allow-missing' might influence metrics when some references are ignored!\n"
        end
        puts 'Start Loading...'
      end

      unless File.exist?(file.to_s) || OPTIONS[:output_format] == 'stdout'
        Dim::ExitHelper.exit(code: 1, filename: file,
                             msg: 'does not exist')
      end

      @dim_file = OPTIONS[:output_format] == 'stdout' ? $stdin.read.chomp : File.binread(file).chomp

      if attributes_file
        fetch_attributes!(folder: File.dirname(attributes_file), filename: attributes_file.split('/').last,
                          silent: silent)
      elsif !dim_file.match(/^Config:/)
        folder = search_attributes_file(file.to_s)
        fetch_attributes!(folder: folder, filename: 'attributes.dim', silent: silent) if folder
      end

      if dim_file.match(/^Config:/)
        load_config(config_filename: file.to_s, silent: silent)
      else
        load_pattern(
          config_filename: nil,
          pattern: file.to_s,
          origin: '',
          silent: silent,
          category: 'unspecified',
          disable_naming_convention_check: false,
          no_check_enclosed: no_check_enclosed
        )
      end

      puts 'Checking consistency...' unless silent
      checker = Dim::Consistency.new(self)
      checker.check(allow_missing: allow_missing)
      puts 'Done.' unless silent
    ensure
      ::Psych::Nodes::Scalar.revert_patch
      ::Psych::Visitors::ToRuby.revert_patch
    end

    def load_config(config_filename:, silent: true, no_check_enclosed: false)
      puts "Loading [config] #{config_filename}..." unless silent
      @config = open_yml_file(config_filename, '')

      allowed_attributes = %w[Config Properties Attributes]

      @config.each_key do |k|
        next unless allowed_attributes.none? { |a| a == k }

        Dim::ExitHelper.exit(code: 1, filename: config_filename, msg: "top level key in config file must be #{allowed_attributes.map do |a|
                                                                                                                "\"#{a}\""
                                                                                                              end.join(', ')}, found \"#{k}\"")
      end

      if @config.key?('Attributes')
        if @config['Attributes'].is_a?(String)
          fetch_attributes!(folder: File.dirname(config_filename), filename: @config['Attributes'], silent: silent)
        else
          Dim::ExitHelper.exit(code: 1, filename: config_filename, msg: "'Attributes' must be a string")
        end
      end

      if @config.key?('Properties')
        if @config['Properties'].is_a?(String)
          resolve_properties(folder: File.dirname(config_filename), properties_filename: @config['Properties'])
        else
          Dim::ExitHelper.exit(code: 1, filename: config_filename, msg: "'Properties' must be a string")
        end
      end

      # COP: Move to constants
      allowed_keys = %w[files category originator disable_naming_convention_check]
      allowed_categories = ALLOWED_CATEGORIES.values

      if @config['Config'].is_a?(Array)
        config_values = @config['Config']
      else
        Dim::ExitHelper.exit(code: 1, filename: config_filename, msg: "'Config' must be an array")
      end

      config_values.each do |value|
        validate_and_load_config(value, config_filename)

        unless value.is_a?(Hash) && value.keys.sort_by(&:length).eql?(allowed_keys.sort_by(&:length))
          Dim::ExitHelper.exit(code: 1, filename: config_filename,
                               msg: "each hash in 'Config' array must have key/value pairs for #{allowed_keys.join(', ')}.")
        end

        if value['category'].is_a?(String)
          value['category'].strip!
          unless allowed_categories.include?(value['category'])
            Dim::ExitHelper.exit(code: 1, filename: config_filename,
                                 msg: "attribute \"category\" of '#{value['originator']}' reqs is '#{value['category']}' but must be one of #{allowed_categories.join(', ')}.")
          end
        else
          Dim::ExitHelper.exit(code: 1, filename: config_filename,
                               msg: "attribute \"category\" of '#{value['originator']}' reqs must be a string")
        end

        if value['files'].is_a?(Array) && value['files'].all? { |a| a.is_a?(String) } || value['files'].is_a?(String)
          value['files'] = *value['files']
        else
          Dim::ExitHelper.exit(code: 1, filename: config_filename,
                               msg: "attribute \"files\" of '#{value['originator']}' reqs must be a string or an array of strings.")
        end
        value['files'].each do |pattern|
          pattern.gsub!(%r{\A\./}, '')
          if pattern.empty?
            Dim::ExitHelper.exit(code: 1, filename: config_filename,
                                 msg: "attribute \"files\" of '#{value['originator']}' must not have an empty string")
          end
          p = Pathname.new(pattern)
          if p.absolute?
            Dim::ExitHelper.exit(code: 1, filename: config_filename,
                                 msg: "'#{pattern}' must not be an absolute path")
          end
          if p.each_filename.any? { |e| e == '..' }
            Dim::ExitHelper.exit(code: 1, filename: config_filename,
                                 msg: "'#{pattern}' must not include '..'")
          end
          load_pattern(
            config_filename: config_filename,
            pattern: pattern,
            origin: value['originator'],
            silent: silent,
            category: value['category'],
            disable_naming_convention_check: value['disable_naming_convention_check'],
            no_check_enclosed: no_check_enclosed
          )
        end
      end
      puts 'Done.' unless silent
    end

    def extract_type(attr)
      return {} if attr.empty?

      hscan = attr.scan(/\Ah(\d+)\s.+/)
      if hscan.length == 1
        level = hscan[0][0].to_i
        return { 'type' => "heading_#{level}", 'text' => attr[2 + hscan[0][0].length..].strip }
      else
        iscan = attr.scan(/\Ainfo\s.+/)
        return { 'type' => 'information', 'text' => attr[5..].strip } if iscan.length == 1
      end
      nil
    end

    def load_file(filename:, origin:, silent:, category:, disable_naming_convention_check: false,
                  no_check_enclosed: false)
      puts "Loading [#{origin.empty? ? 'unknown' : origin}] #{filename}..." unless silent
      binary_data = OPTIONS[:output_format] == 'stdout' ? @dim_file : File.binread(filename).force_encoding('UTF-8')

      # this looks expensive but measurement showed it's close to zero
      @@invalid_ccs.each { |k, v| binary_data = binary_data.gsub(k, v) }

      if binary_data.valid_encoding?
        begin
          psych_doc = YAML.parse(binary_data)
        rescue Psych::SyntaxError => e
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: e.message)
        end
      else
        begin
          psych_doc = YAML.parse(binary_data.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'),
                                 filename: filename)
        rescue Psych::SyntaxError => e
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: e.message)
        end
      end
      unless psych_doc
        puts "Warning: empty file detected; skipped loading of #{filename}"

        return
      end
      reqs = psych_doc.to_ruby

      unless reqs.is_a?(Hash)
        Dim::ExitHelper.exit(code: 1, filename: filename,
                             msg: 'top level must be a hash with keys "module", "enclosed", "metadata" and/or unique ids')
      end

      # TODO: Remove module backward compatibility in future version
      if reqs.key?('document') && reqs.key?('module')
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: 'module and document found in the file; please rename module to document'
        )
      end

      if reqs.key?('document')
        if !reqs['document'].is_a?(String) || reqs['document'].empty?
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'document must be a non-empty string')
        end
        document = reqs['document']
        # TODO: Remove module backward compatibility in future version
        reqs['module'] = document
      elsif reqs.key?('module')
        if !(reqs['module'].is_a? String) || reqs['module'].empty?
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'module name must be a non-empty string')
        end
        document = reqs['module']
        reqs['document'] = document
      else
        Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'Document name is missing; please add document name')
      end

      validate_srs_name(document, disable_naming_convention_check, category, filename)

      if @module_data.key?(document)
        if @module_data[document][:origin] != origin
          Dim::ExitHelper.exit(code: 1, filename: filename, msg:
            "files of the same module must have the same owner:\n" \
            "- #{@module_data[document][:files].first[0]} (#{@module_data[document][:origin]})\n" \
            "- #{filename} (#{origin})")
        elsif @module_data[document][:category] != category
          Dim::ExitHelper.exit(code: 1, filename: filename, msg:
            "files of the same module must have the same category:\n" \
            "- #{@module_data[document][:files].first[0]} (#{@module_data[document][:category]})\n" \
            "- #{filename} (#{category})")
        end
      else
        @module_data[document] = { origin: origin, category: category, files: {} }
      end

      if @module_data[document][:files].key?(filename)
        Dim::ExitHelper.exit(code: 1, filename: filename, msg: "file #{filename} already loaded")
      end

      @module_data[document][:files][filename] = []
      @metadata[document] ||= ''

      if reqs.key?('metadata')
        unless reqs['metadata'].is_a?(String)
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'metadata must be a string')
        end
        unless reqs['metadata'].empty?
          unless @metadata[document].empty?
            Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'only one metadata per module allowed')
          end
          @metadata[document] = reqs['metadata'].strip
        end
      end

      if reqs.key?('enclosed') && !no_check_enclosed
        ecl = reqs['enclosed']
        ecl = [ecl] if ecl.is_a?(String)
        if !ecl.is_a?(Array) || ecl.empty? || ecl.any? { |s| !s.is_a?(String) || s.empty? }
          Dim::ExitHelper.exit(code: 1, filename: filename,
                               msg: '"enclosed" must be a non-empty string or an array of non-empty strings')
        end
        # Remove superfluous ./ from path
        ecl = ecl.map do |path|
          if path.match?(/\\/)
            puts "Warning: Backward slashes detected in filepath #{path}. Use '/' over '\\' in filepath"
            path.gsub!('\\', '/')
          end
          Pathname.new(path).cleanpath.to_s
        end
        dir_file = File.dirname(filename)
        ecl.each do |l|
          p = Pathname.new(l)
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: "'#{l}' must not be an absolute path") if p.absolute?
          if p.each_filename.any? do |name|
            name == '..'
          end
            Dim::ExitHelper.exit(code: 1, filename: filename,
                                 msg: "'#{l}' must not include '..'")
          end

          src = File.join(dir_file, l)
          src_globbed = Dir.glob(src)
          if src_globbed.empty?
            Dim::ExitHelper.exit(code: 1, filename: filename,
                                 msg: "\"#{l}\" in \"enclosed\" does not refer to any existing file")
          end
        end
        @module_data[document][:files][filename] += ecl
      end

      line_numbers = psych_doc.line_numbers

      reqs.each do |id, attr|
        next if %w[module enclosed metadata document].include? id

        if @requirements.key?(id)
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: "id \"#{id}\" found more than once")
        end

        if id.include?(',')
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: "Disallowed ',' found in id \"#{id}\"")
        end

        validate_srs_name(id, disable_naming_convention_check, category, filename, 'ID')

        if attr.is_a?(String)
          attr.strip!
          res = extract_type(attr)
          if res
            attr = res
          else
            Dim::ExitHelper.exit(code: 1, filename: filename,
                                 msg: "Invalid short-form in requirement \"#{id}\", valid forms are \"h<level> <text>\" or \"info <text>\"")
          end
        elsif attr.is_a?(Hash)
          attr.keys.select do |k|
            @all_attributes.key?(k) && %i[multi split].include?(@all_attributes[k][:format_style])
          end.each do |k|
            attr[k] = attr[k].cleanUniqString if attr[k].is_a?(String)
          end
          attr['tags'] = attr['tags'].cleanUniqString if attr['tags'].is_a?(String)
        else
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: "attributes for id \"#{id}\" must be key-value pairs")
        end
        if !attr.key?('verification_methods') && attr.key?('test_setups')
          attr['verification_methods'] = attr['test_setups']
        end
        attr.each do |key, value|
          unless value.is_a?(String)
            Dim::ExitHelper.exit(code: 1, filename: filename,
                                 msg: "value of attribute \"#{key}\" must be String not #{value.class}")
          end
          attr[key].gsub!("\u00A0", ' ')
          attr[key].strip!
        end

        r = Requirement.new(id, document, filename, attr, origin, self, category, line_numbers[id], @all_attributes)
        reqs[id] = attr
        @requirements[id] = r
      end

      @original_data[filename] = Marshal.load(Marshal.dump(reqs))
    end

    def load_pattern(config_filename:, pattern:, origin:, silent:, category:, disable_naming_convention_check: false,
                     no_check_enclosed: false)
      if pattern.match?(/\\/)
        puts "Warning: Backward slashes detected in pattern #{pattern}. Use '/' over '\\'"
        pattern.gsub!('\\', '/')
      end
      pattern_search = config_filename ? File.join(File.dirname(config_filename), pattern) : pattern
      fs = Dir.glob(pattern_search).sort
      puts "Info: no matches for \"#{pattern}\" in \"#{config_filename}\"" if fs.empty? && !silent
      fs.each do |f|
        load_file(filename: f, origin: origin, silent: silent, category: category,
                  disable_naming_convention_check: disable_naming_convention_check, no_check_enclosed: no_check_enclosed)
      end
      return unless OPTIONS[:output_format] == 'stdout'

      load_file(filename: '', origin: origin, silent: silent, category: category,
                disable_naming_convention_check: disable_naming_convention_check, no_check_enclosed: no_check_enclosed)
    end

    def resolve_properties(folder:, properties_filename:)
      @properties = open_yml_file(folder, properties_filename, allow_empty_file: true)
      unless @properties
        puts "Warning: empty file detected; skipped loading of #{properties_filename}"
        return
      end

      @properties.each do |document, value|
        value.each do |attr, property_value|
          next unless @all_attributes.key?(attr)

          unless property_value.is_a?(String)
            Dim::ExitHelper.exit(code: 1, filename: properties_filename,
                                 msg: "The value for key #{attr} in properties files must be a string")
          end

          if @all_attributes.dig(attr, :allowed).nil? ||
             property_value.cleanArray.reject do |val|
               @all_attributes[attr][:allowed].include?(val)
             end.none?
            @property_table[document] ||= {}
            @property_table[document][attr] = property_value.strip
          else
            Dim::ExitHelper.exit(code: 1, filename: properties_filename,
                                 msg: "The properties file includes an invalid #{attr} value '#{property_value}' for module: #{document}.")
          end
        end
      end
    end

    def fetch_attributes!(folder:, filename:, silent:)
      puts "Loading [attributes] #{File.join(folder, filename)}" unless silent

      @custom_attributes.merge!(resolve_attributes(folder: folder, filename: filename))
      @all_attributes.merge!(@custom_attributes)
    end

    def search_attributes_file(file)
      path = Pathname.new(file).parent.realpath
      if path.root?
        nil
      else
        return path if Dir.new(path).children.include?('attributes.dim')

        search_attributes_file(path)
      end
    end

    def validate_and_load_config(value, config_filename)
      disable_naming_convention_check = value['disable_naming_convention_check']
      unless disable_naming_convention_check
        value['disable_naming_convention_check'] = false
        return
      end

      if value['category'] != ALLOWED_CATEGORIES[:software]
        warn('Warning: disable_naming_convention_check attribute will only take effect when category is software')
      end

      if disable_naming_convention_check == 'yes'
        value['disable_naming_convention_check'] = true
        return
      elsif disable_naming_convention_check == 'no'
        value['disable_naming_convention_check'] = false
        return
      end

      Dim::ExitHelper.exit(
        code: 1,
        filename: config_filename,
        msg: 'disable_naming_convention_check in config must be either boolean value or a string "yes" or "no"'
      )
    end

    def validate_srs_name(name, disable_naming_convention_check, category, filename, attr = 'module')
      return if category != ALLOWED_CATEGORIES[:software] || disable_naming_convention_check

      # raise error if not starting with SRS_
      unless name.match?(/^(SRS_)/)
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "#{attr} #{name} in software requirement must start with \"SRS_\""
        )
      end

      _srs, feature, aspect, *rest = name.split('_')

      # Raise error if more than two _ detected
      unless rest.empty?
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "#{attr} #{name} in software requirement must contain exactly two \"_\""
        )
      end

      if feature.to_s.empty?
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "invalid #{attr} #{name} in software requirement; missing feature after \"SRS_\""
        )
      end

      # Raise error if feature or aspect is non alphanumeric
      if feature.match?(SRS_NAME_REGEX)
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "feature in #{attr} #{name} in software requirement contains non-alphanumeric characters"
        )
      end

      if attr == 'module' && !aspect.to_s.empty?
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "invalid module #{name} in software requirement; must contain exactly one \"_\""
        )
      end

      # Check naming convention for aspect only in case of IDs
      return if attr == 'module'

      if aspect.to_s.empty?
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "invalid ID #{name} in software requirement; missing aspect/ratio after \"SRS_feature\""
        )
      end

      return unless aspect.match?(SRS_NAME_REGEX)

      Dim::ExitHelper.exit(
        code: 1,
        filename: filename,
        msg: "aspect in ID #{name} in software requirement contains non-alphanumeric characters"
      )
    end
  end
end
