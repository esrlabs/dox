require 'json'

require_relative '../globals'
require_relative '../requirement'

module Dim
  class Json < ExporterInterface
    EXPORTER['json'] = self

    def header(_f)
      @content = []
    end

    def requirement(_f, r)
      vals = { 'id' => r.id, 'document_name' => r.document, 'originator' => r.origin }

      @loader.all_attributes.each_key do |k|
        next if k == 'test_setups'

        v = r.data[k]
        v = v.cleanUniqArray.join(',') if k == 'refs'
        vals[k] = v.strip
      end

      @content << vals
    end

    def footer(f)
      f.puts(JSON.pretty_generate(@content))
    end
  end
end
