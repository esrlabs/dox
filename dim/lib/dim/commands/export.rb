require 'pathname'
require 'digest'

require_relative '../globals'
require_relative '../exporter/exporterInterface'
require_relative '../exporter/rst'
require_relative '../exporter/csv'
require_relative '../exporter/json'
require_relative 'check'

module Dim
  class Export
    SUBCOMMANDS['export'] = self

    attr_accessor :file_list, :export_dir

    def initialize(loader)
      @loader = loader
      @file_list = []
      @export_dir = nil
    end

    def execute(silent: true)
      @silent = silent
      @loader.filter(OPTIONS[:filter]) unless OPTIONS[:filter].empty?

      puts 'Exporting...' unless @silent
      export
      clean_destination
      puts 'Done.' unless @silent
    end

    def copy_files(mod)
      @loader.module_data[mod][:files].each do |f, list|
        d = File.dirname(f)

        list.uniq.each do |l|
          src_pattern = File.join(d, l)
          Dir.glob(src_pattern).each do |src|
            src = Pathname.new(src).cleanpath.to_s
            dst = File.join(OPTIONS[:folder], mod.sanitize, Pathname.new(src).relative_path_from(Pathname(d)))
            @file_list << dst
            FileUtils.mkdir_p(File.dirname(dst))

            if File.exist?(dst)
              md5_src = Digest::MD5.file(src)
              md5_dst = Digest::MD5.file(dst)
              next if md5_src == md5_dst
            end

            puts "Copying #{src} to #{dst}..." unless @silent
            FileUtils.cp_r(src, dst)
          end
        end
      end
    end

    def write_content(filename, content)
      old_content = (File.exist?(filename) ? File.read(filename) : nil)
      if content != old_content
        File.write(filename, content)
        puts ' done' unless @silent
      else
        puts ' skipped' unless @silent
      end
    end

    def create_index(requirements_by_module)
      return unless @exporter.hasIndex

      files = {}
      @loader.module_data.each do |mod, data|
        next if requirements_by_module[mod].empty?

        c = data[:category]
        o = data[:origin]
        files[c] ||= {}
        files[c][o] ||= []
        files[c][o] << mod
      end
      ind = 0
      files.each do |category, data|
        data.each do |origin, modules|
          ind += 1
          filename = "index_#{format('%03d', ind)}_#{category.downcase}_#{origin.downcase.sanitize}"
          filepath = "#{OPTIONS[:folder]}/#{filename}.#{OPTIONS[:type]}"
          file_list << filepath
          new_content = StringIO.new
          print "Creating #{filepath}..." unless @silent
          @exporter.index(new_content, category, origin, modules)
          write_content(filepath, new_content.string)
        end
      end
    end

    def export
      requirements_by_module = {}
      module_keys = @loader.module_data.keys
      module_keys.each { |um| requirements_by_module[um] = [] }
      @loader.requirements.each_value { |r| requirements_by_module[r.document] << r }

      @exporter = EXPORTER[OPTIONS[:type]].new(@loader)
      requirements_by_module.each do |doc, reqs|
        next if reqs.empty?

        @export_dir = File.join(OPTIONS[:folder])
        filename = File.join(export_dir, doc.sanitize, "Requirements.#{OPTIONS[:type]}")
        file_list << filename
        FileUtils.mkdir_p(File.dirname(filename))
        copy_files(doc)

        new_content = StringIO.new
        print "Creating #{filename}..." unless @silent
        @exporter.header(new_content)
        @exporter.document(new_content, doc)
        meta = @loader.metadata[doc]
        @exporter.metadata(new_content, meta) if meta != ''
        reqs.each do |r|
          @exporter.requirement(new_content, r)
        end
        @exporter.footer(new_content)
        write_content(filename, new_content.string)
      end

      create_index(requirements_by_module)
    end

    def clean_destination(dir_path = export_dir)
      Dir.new(dir_path).children.each do |file|
        dst = File.join(dir_path, file)
        path = Pathname.new(dst)

        clean_destination(dst) if path.directory?

        next if file_list.include? dst

        if path.directory?
          path.rmdir if path.empty?
        else
          path.delete
        end
      end
    end
  end
end
