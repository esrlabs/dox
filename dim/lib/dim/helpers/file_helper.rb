# frozen_string_literal: true

require_relative '../exit_helper'

module Dim
  module Helpers
    module FileHelper
      def open_yml_file(folder, filename, allow_empty_file: false)
        file_path = Pathname.new(File.join(folder, filename)).cleanpath.to_s
        binary_data = File.binread(file_path).chomp
        begin
          data = YAML.parse(
            binary_data.encode('utf-8', invalid: :replace, undef: :replace, replace: '?'),
            filename: file_path
          )
        rescue Psych::SyntaxError => e
          Dim::ExitHelper.exit(code: 1, filename: filename, msg: e.message)
        end

        Dim::ExitHelper.exit(code: 1, filename: filename, msg: 'not a valid yaml file') unless data || allow_empty_file
        return unless data

        data.to_ruby
      end
    end
  end
end
