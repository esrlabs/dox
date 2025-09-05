require 'json'

module Dim
  class Rst < ExporterInterface
    EXPORTER['rst'] = self

    def initialize(loader)
      super(loader)
      @has_index = true
    end

    def document(file_io, name)
      raw_html_name = ":raw-html:`#{name}`"
      file_io.puts raw_html_name
      file_io.puts '=' * raw_html_name.length
      @last_heading_level = 0
      @module_name = name
    end

    def metadata(file_io, meta)
      file_io.puts ''
      file_io.puts html(meta.strip.escape_html, with_space: false)
    end

    def level2char(level)
      { 0 => '=',
        1 => '-',
        2 => '+',
        3 => '~',
        4 => '^',
        5 => '"' }.fetch(level, '"')
    end

    def html(elem, with_space: true)
      return if elem.empty?

      with_space ? " :raw-html:`#{elem}`" : ":raw-html:`#{elem}`"
    end

    def handle_empty_value(value)
      return '' if value.empty?

      " #{value.is_a?(Array) ? value.join(', ') : value}"
    end

    def create_multi_language_element(req, name)
      lang_elems = req.data.keys.select { |key| key.start_with?("#{name}_") && !req.data[key].empty? }.sort
      if lang_elems.empty?
        return req.data[name].empty? ? '' : req.data[name]
      end

      str = (req.data[name].empty? ? '-' : req.data[name])
      lang_elems.each do |l|
        str << "<br><br><b>#{l.split('_').map(&:capitalize).join(' ')}: </b>"
        str << req.data[l]
      end
      str
    end

    def requirement(file_io, req)
      req.data.each { |k, v| req.data[k] = v.strip.escape_html }

      if req.data['type'].start_with?('heading')
        (@last_heading_level + 1...req.depth).each do |l|
          str = '<Skipped Heading Level>'
          file_io.puts ''
          file_io.puts str
          file_io.puts level2char(l) * str.length
        end
        file_io.puts ''
        str = ":raw-html:`#{req.data['text']}`"
        file_io.puts str
        file_io.puts level2char(req.depth) * str.length
        @last_heading_level = req.depth
        return
      end

      req.data['tester'].gsub!('<br>', ' ')
      req.data['developer'].gsub!('<br>', ' ')
      text = create_multi_language_element(req, 'text')
      comment = create_multi_language_element(req, 'comment')
      refs = req.data['refs'].cleanUniqArray.select do |ref|
        !@loader.requirements.key?(ref) || !@loader.requirements[ref].type.start_with?('heading')
      end
      tags = req.data['tags'].cleanUniqString
      sources = req.data['sources'].cleanUniqString

      file_io.puts ''
      file_io.puts ".. #{req.type}:: #{req.id}"
      file_io.puts "    :category: #{req.category}"
      file_io.puts "    :status: #{req.status}"
      file_io.puts "    :review_status: #{req.review_status}"
      file_io.puts "    :asil: #{req.asil}"
      file_io.puts "    :cal: #{req.cal}"
      file_io.puts "    :tags:#{handle_empty_value(tags)}"
      file_io.puts "    :comment:#{html(comment)}"
      file_io.puts "    :miscellaneous:#{html(req.miscellaneous)}"
      file_io.puts "    :refs:#{handle_empty_value(refs)}"
      @loader.custom_attributes.each_key do |custom_attribute|
        file_io.puts "    :#{custom_attribute}:#{handle_empty_value(req.data[custom_attribute])}"
      end
      if req.data['type'] == 'requirement'
        vc = create_multi_language_element(req, 'verification_criteria')

        file_io.puts "    :sources:#{handle_empty_value(sources)}"
        file_io.puts "    :feature:#{html(req.feature)}"
        file_io.puts "    :change_request:#{html(req.change_request)}"
        file_io.puts "    :developer:#{handle_empty_value(req.developer)}"
        file_io.puts "    :tester:#{handle_empty_value(req.tester)}"
        file_io.puts "    :verification_methods:#{handle_empty_value(req.verification_methods)}"
        file_io.puts "    :verification_criteria:#{html(vc)}"
      end

      file_io.puts "\n   #{html(text)}" unless text.empty?
    end

    def footer(file_io)
      files = @loader.module_data[@module_name][:files].values.flatten
      return if files.empty?

      file_io.puts ''
      file_io.puts '.. enclosed::'
      file_io.puts ''
      files.each do |file|
        file_io.puts "    #{file}"
      end
    end

    def index(file_io, category, origin, modules)
      caption = "#{category.capitalize} (#{origin})"
      file_io.puts caption
      file_io.puts '=' * caption.length
      file_io.puts ''
      file_io.puts '.. toctree::'
      file_io.puts '  :maxdepth: 1'
      file_io.puts ''
      modules.sort.each do |m|
        file_io.puts "  #{m.sanitize}/Requirements"
      end
    end
  end
end
