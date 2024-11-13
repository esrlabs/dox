require 'set'

require_relative 'globals'
require_relative 'exit_helper'
require_relative 'ext/string'

module Dim
  class Requirement
    attr_accessor :data, :moduleName, :document, :depth, :id, :origin, :loader, :existingRefs, :backwardRefs, :filename,
                  :category, :line_number, :all_attributes, :upstreamRefs, :downstreamRefs, :category_level

    # rubocop:disable Layout/LineLength, Layout/HashAlignment
    SYNTAX = {
      'type'                  => { check: :check_single_enum, format_style: :single, format_shift:  0, default: 'requirement',
                                   allowed: %w[requirement information heading_<level>] },
      'text'                  => { check: nil,                format_style: :text,   format_shift: 28, default: '',             allowed: nil },
      'verification_criteria' => { check: nil,                format_style: :text,   format_shift: 32, default: '',             allowed: nil },
      'feature'               => { check: nil,                format_style: :text,   format_shift:  0, default: '',             allowed: nil },
      'change_request'        => { check: nil,                format_style: :text,   format_shift:  0, default: '',             allowed: nil },
      'tags'                  => { check: nil,                format_style: :list,   format_shift:  0, default: '',             allowed: nil },
      'asil'                  => { check: :check_single_enum, format_style: :single, format_shift:  0, default: 'not_set',
                                   allowed: %w[not_set
                                               QM QM(A) QM(B) QM(C) QM(D)
                                               ASIL_A ASIL_A(A) ASIL_A(B) ASIL_A(C) ASIL_A(D)
                                               ASIL_B ASIL_B(B) ASIL_B(C) ASIL_B(D)
                                               ASIL_C ASIL_C(C) ASIL_C(D)
                                               ASIL_D ASIL_D(D)] },
      'cal'                   => { check: :check_single_enum, format_style: :single, format_shift:  0, default: 'not_set',
                                   allowed: %w[QM CAL_1 CAL_2 CAL_3 CAL_4 not_set] },
      'developer'             => { check: nil,                format_style: :list,   format_shift:  0, default: nil,             allowed: nil },
      'tester'                => { check: nil,                format_style: :list,   format_shift:  0, default: nil,             allowed: nil },
      'test_setups'           => { check: :check_multi_enum,  format_style: :multi,  format_shift:  0, default: nil,
                                   allowed: %w[none off_target on_target manual] },
      'verification_methods'  => { check: :check_multi_enum, format_style: :multi, format_shift:  0,   default: nil,
                                   allowed: %w[none off_target on_target manual] },
      'status'                => { check: :check_single_enum, format_style: :single, format_shift:  0, default: nil,
                                   allowed: %w[valid draft invalid] },
      'review_status'         => { check: :check_single_enum, format_style: :single, format_shift:  0, default: nil,
                                   allowed: %w[accepted unclear rejected not_reviewed not_relevant] },
      'comment'               => { check: nil,                format_style: :text,   format_shift:  0, default: '',             allowed: nil },
      'miscellaneous'         => { check: nil,                format_style: :text,   format_shift:  0, default: '',             allowed: nil },
      'sources'               => { check: nil,                format_style: :split,  format_shift:  0, default: '',             allowed: nil },
      'refs'                  => { check: nil,                format_style: :split,  format_shift:  0, default: '',             allowed: nil }
    }
    # rubocop:enable Layout/LineLength, Layout/HashAlignment

    # this allows easy access to attribute names
    SYNTAX.each_key do |k|
      if %i[list multi split].include?(SYNTAX[k][:format_style])
        define_method(k) do
          @data[k].cleanUniqArray
        end
      else
        define_method(k) do
          @data[k]
        end
      end
    end

    def safety_relevant?
      !%w[QM not_set].include?(@data['asil'])
    end

    def security_relevant?
      !%w[QM not_set].include?(@data['cal'])
    end

    # this allows writing enum values without " in filter
    alias method_missing_org method_missing
    def method_missing(sym, *_args)
      str = sym.to_s
      return str if /\Aheading_(\d+)\z/ === str
      return str if SYNTAX.any? { |_name, attr| attr[:allowed].is_a?(Array) && attr[:allowed].include?(str) }
      return str if %w[input software architecture module system].include?(str)

      Dim::ExitHelper.exit(code: 1, msg: "\"#{str}\" is not a requirement attribute")
    end

    def filter(str)
      eval(str)
    end

    def initialize(id, document, filename, attr, origin, loader, category, line_number, all_attributes)
      @id = id
      @moduleName = document
      @document = document
      @filename = filename
      @data = attr
      @origin = origin
      @existingRefs = [] # needed later for "missing links" feature
      @backwardRefs = []
      @upstreamRefs = []
      @downstreamRefs = []
      @loader = loader
      @category = category
      @category_level = CATEGORY_ORDER[category] || 0
      @line_number = line_number
      @all_attributes = all_attributes

      define_custom_attribute_methods
      calc_depth

      check_unknown_keys
      check_invalid_values
      # TODO: Remove after completely removing test_setups
      merge_test_setups_and_verification_methods
      check_verification_methods
    end

    def define_custom_attribute_methods
      new_attributes = @all_attributes.keys - SYNTAX.keys
      new_attributes.each do |k|
        define_singleton_method(k) do
          @data[k]
        end
      end
    end

    def calc_depth
      @depth = 1
      hres = @data['type']&.scan(/^heading_(\d+)$/) || ''
      return unless hres.length.positive?

      dep = hres[0][0].to_i
      return unless dep > 1

      if dep > 100
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "heading level above 100 is not allowed and makes absolutely no sense: #{@data['type']}"
        )
      end

      @depth = dep
    end

    def check_single_enum(elem, key, value)
      unless !elem[:allowed].include?(value) && !(elem[:allowed].include?('heading_<level>') && /\Aheading_\d+\Z/ === value)
        return
      end

      allowed_values = elem[:allowed].reject { |a| a.nil? || a.empty? }.map { |e| "\"#{e}\"" }.join(', ')
      Dim::ExitHelper.exit(
        code: 1,
        filename: filename,
        msg: "attribute \"#{key}\" must not be \"#{value}\" (id: #{@id}). \"#{key}\" must be exactly " \
        "one of #{allowed_values}. #{"Default is \"#{elem[:default]}\"" if elem[:default]}."
      )
    end

    def check_multi_enum(element, key, value)
      value_array = value.cleanArray
      value_array = [''] if value == ''
      value_array.each do |v|
        next if element[:allowed].include?(v)

        allowed_values = element[:allowed].reject { |a| a.nil? || a.empty? }.map { |e| "\"#{e}\"" }.join(', ')
        Dim::ExitHelper.exit(
          code: 1,
          filename: filename,
          msg: "attribute \"#{key}\" is invalid: \"#{v}\" (id: #{@id}). \"#{key}\" must be one or " \
                 "more of #{allowed_values}."
        )
      end
    end

    def check_unknown_keys
      ks = @all_attributes.keys
      # sort reverse so that language keys are inserted into Requirement::SYNTAX in alphabetical order
      @data.keys.sort.reverse.each do |k|
        if /\A(text_|verification_criteria_|comment_)./ === k
          unless @all_attributes.include?(k)
            reference_key = k.gsub(/(text|verification_criteria|comment).*/, '\\1')
            reference_settings = @all_attributes[reference_key]
            # rebuild the hash to change the iteration order for later processing like formatting
            tmp = @all_attributes.dup
            @all_attributes.clear
            tmp.each do |key, value|
              @all_attributes[key] = value
              next unless key == reference_key

              @all_attributes[k] = {
                check: nil,
                new: '',
                default: '',
                allowed: nil,
                format_style: reference_settings[:format_style],
                format_shift: reference_settings[:format_shift]
              }
            end
            loader.requirements.each_value { |r| r.data[k] = '' }
            Dim::Requirement.define_method(k) do
              @data[k]
            end
          end
          next
        end

        Dim::ExitHelper.exit(code: 1, filename: filename, msg: "attribute #{k} not allowed") unless ks.include?(k)
      end
    end

    def check_invalid_values
      @data.each do |k, v|
        if @all_attributes.key?(k) && (@all_attributes[k][:check])
          send(@all_attributes[k][:check], @all_attributes[k], k, v)
        end
      end
    end

    def merge_test_setups_and_verification_methods
      # Given verification_methods is empty
      # Given test_setups contains None
      # Then return None
      ts = @data['test_setups']&.cleanArray || []
      vm = @data['verification_methods']&.cleanArray || []

      return if vm.empty? && ts.empty?

      merged = ts.union(vm).join(', ')
      @data['test_setups'] = merged
      @data['verification_methods'] = merged
    end

    def check_verification_methods
      vm = @data['verification_methods']&.cleanArray || []
      return unless vm.include?('none') && vm.length > 1

      vm.delete('none')
      Dim::ExitHelper.exit(code: 1,
                           filename: filename,
                           msg: "verification_methods or test_setups for \"#{@id}\" can't include 'none' along with #{vm.join(', ')}.")
    end
  end
end
