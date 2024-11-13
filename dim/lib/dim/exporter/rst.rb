require 'json'

module Dim
  class Rst < ExporterInterface
    EXPORTER['rst'] = self

    def initialize(loader)
      super(loader)
      @hasIndex = true
    end

    def document(f, name)
      raw_html_name = ":raw-html:`#{name}`"
      f.puts raw_html_name
      f.puts '=' * raw_html_name.length
      @lastHeadingLevel = 0
      @moduleName = name
    end

    def metadata(f, meta)
      f.puts ''
      f.puts html(meta.strip.escape_html, with_space: false)
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

    def createMultiLanguageElement(r, name)
      lang_elems = r.data.keys.select { |k| k.start_with?("#{name}_") && !r.data[k].empty? }.sort
      if lang_elems.empty?
        return r.data[name].empty? ? '' : r.data[name]
      end

      str = (r.data[name].empty? ? '-' : r.data[name])
      lang_elems.each do |l|
        str << "<br><br><b>#{l.split('_').map(&:capitalize).join(' ')}: </b>"
        str << r.data[l]
      end
      str
    end

    def requirement(f, r)
      r.data.each { |k, v| r.data[k] = v.strip.escape_html }

      if r.data['type'].start_with?('heading')
        (@lastHeadingLevel + 1...r.depth).each do |l|
          str = '<Skipped Heading Level>'
          f.puts ''
          f.puts str
          f.puts level2char(l) * str.length
        end
        f.puts ''
        str = ":raw-html:`#{r.data['text']}`"
        f.puts str
        f.puts level2char(r.depth) * str.length
        @lastHeadingLevel = r.depth
        return
      end

      r.data['tester'].gsub!('<br>', ' ')
      r.data['developer'].gsub!('<br>', ' ')
      text = createMultiLanguageElement(r, 'text')
      comment = createMultiLanguageElement(r, 'comment')
      refs = r.data['refs'].cleanUniqArray.select do |ref|
        !@loader.requirements.key?(ref) || !@loader.requirements[ref].type.start_with?('heading')
      end
      tags = r.data['tags'].cleanUniqString
      sources = r.data['sources'].cleanUniqString

      f.puts ''
      f.puts ".. #{r.data['type']}:: #{r.id}"
      f.puts "    :category: #{r.category}"
      f.puts "    :status: #{r.data['status']}"
      f.puts "    :review_status: #{r.data['review_status']}"
      f.puts "    :asil: #{r.data['asil']}"
      f.puts "    :cal: #{r.data['cal']}"
      f.puts "    :tags:#{handle_empty_value(tags)}"
      f.puts "    :comment:#{html(comment)}"
      f.puts "    :miscellaneous:#{html(r.data['miscellaneous'])}"
      f.puts "    :refs:#{handle_empty_value(refs)}"
      @loader.custom_attributes.each_key do |custom_attribute|
        f.puts "    :#{custom_attribute}:#{handle_empty_value(r.data[custom_attribute])}"
      end
      if r.data['type'] == 'requirement'
        vc = createMultiLanguageElement(r, 'verification_criteria')

        f.puts "    :sources:#{handle_empty_value(sources)}"
        f.puts "    :feature:#{html(r.data['feature'])}"
        f.puts "    :change_request:#{html(r.data['change_request'])}"
        f.puts "    :developer:#{handle_empty_value(r.data['developer'])}"
        f.puts "    :tester:#{handle_empty_value(r.data['tester'])}"
        f.puts "    :verification_methods:#{handle_empty_value(r.data['verification_methods'])}"
        f.puts "    :verification_criteria:#{html(vc)}"
      end

      f.puts "\n   #{html(text)}" unless text.empty?
    end

    def footer(f)
      files = @loader.module_data[@moduleName][:files].values.flatten
      return if files.empty?

      f.puts ''
      f.puts '.. enclosed::'
      f.puts ''
      files.each do |file|
        f.puts "    #{file}"
      end
    end

    def index(f, category, origin, modules)
      caption = "#{category.capitalize} (#{origin})"
      f.puts caption
      f.puts '=' * caption.length
      f.puts ''
      f.puts '.. toctree::'
      f.puts '  :maxdepth: 1'
      f.puts ''
      modules.sort.each do |m|
        f.puts "  #{m.sanitize}/Requirements"
      end
    end
  end
end
