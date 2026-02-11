require 'json'

require_relative '../globals'
require_relative '../requirement'

module Dim
  class Json < ExporterInterface
    EXPORTER['json'] = self

    def header(_file_io)
      @content = []
    end

    def requirement(_file_io, req)
      vals = { 'id' => req.id, 'document_name' => req.document, 'originator' => req.origin, 'category' => req.category }

      @loader.all_attributes.each_key do |k|
        v = req.data[k]
        v = v.cleanUniqArray.join(',') if k == 'refs'
        vals[k] = v.strip
      end

      @content << vals
    end

    def footer(file_io)
      file_io.puts(JSON.pretty_generate(@content))
    end
  end
end
