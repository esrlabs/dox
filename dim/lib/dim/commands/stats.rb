module Dim
  class Stats
    SUBCOMMANDS['stats'] = self

    def initialize(loader)
      @loader = loader
    end

    def execute(silent: true)
      print_stats
    end

    def print_owner(type, module_name = nil)
      if type == :all
        top = 'ALL'
        is_owner = proc { |_x| true }
      else # :document
        is_owner = proc { |x| x.document == module_name }
        top = "DOCUMENT: #{module_name}"
      end

      puts "\n#{top}\n#{'-' * top.length}"
      all_reqs = @loader.requirements.values
      reqs_owner = all_reqs.select { |r| is_owner.call(r) }

      num_files = if type == :module
                    @loader.module_data[module_name][:files].length
                  else
                    @loader.module_data.values.map { |e| e[:files].keys }.flatten.length
                  end
      puts "Number of files: #{num_files}"

      if type != :module
        mods = reqs_owner.map(&:document).uniq
        puts "Number of modules: #{mods.count}"
      end

      puts "Number of entries: #{reqs_owner.length}"
      real_reqs_owner = reqs_owner.select { |r| r.data['type'] == 'requirement' }
      puts "Requirements: #{real_reqs_owner.length}"
      valid_reqs = real_reqs_owner.select { |r| r.data['status'] == 'valid' }
      puts "Valid requirements: #{valid_reqs.length}"
      accepted = valid_reqs.select { |r| r.data['review_status'] == 'accepted' }
      puts "  Accepted: #{accepted.length}"
      covered = accepted.select { |r| r.data['tags'].include?('covered') }
      puts "    Covered: #{covered.length}"
      not_covered_num = accepted.length - covered.length
      puts "    Not covered: #{not_covered_num}"
      rejected = valid_reqs.select { |r| r.data['review_status'] == 'rejected' }
      puts "  Rejected: #{rejected.length}"
      unclear = valid_reqs.select { |r| r.data['review_status'] == 'unclear' }
      puts "  Unclear: #{unclear.length}"
      not_reviewed = valid_reqs.select { |r| r.data['review_status'] == 'not_reviewed' }
      puts "  Not reviewed: #{not_reviewed.length}"
    end

    def print_stats
      @loader.requirements.values.map(&:document).uniq.each do |mod|
        print_owner(:module, mod)
      end
      print_owner(:all)
    end
  end
end
