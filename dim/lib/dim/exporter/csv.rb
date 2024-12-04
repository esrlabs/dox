require_relative '../globals'
require_relative '../requirement'

module Dim
  class Csv < ExporterInterface
    EXPORTER['csv'] = self

    def header(content)
      @keys = @loader.all_attributes.keys
      content.puts 'Sep=,'
      content.puts "id,document_name,originator,#{@keys.join(',')}"
    end

    def requirement(content, req)
      vals = [req.id, req.document, req.origin]
      @keys.each { |k| vals << req.data[k] }
      # These values will never be nil.
      # ID cannot be nil in Dim file, so as origin (default is "") and
      # document cannot be missing in Dim files.
      # Which leaves with data and YAML file cannot define nil value.
      content.puts(vals.map { |a| "\"#{a.gsub('"', '""')}\"" }.join(','))
    end
  end
end
