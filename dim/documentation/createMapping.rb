$stdout.sync = true

# get annotations from test cases
require_relative '../Rakefile'
require 'json'
Dir.chdir('..') do
  $dry_run = true
  Rake.application['test:spec'].invoke
end
ref_reqs = JSON.parse File.read("#{File.dirname(__FILE__)}/source/pages/requirements-generated/mapping.json")
test_cases = {}
ref_reqs.each do |id, tcs|
  tcs.each do |tc|
    test_cases[tc['location']] ||= []
    test_cases[tc['location']] << id if id != ''
  end
end

# get requirement IDs
require_relative '../lib/dim/loader'
loader = Dim::Loader.new
loader.load(file: "#{File.dirname(__FILE__)}/../req/config.dim")
reqs = loader.requirements.values.select { |r| r.type == 'requirement' }
req_ids = reqs.map(&:id)

# write mapping page
File.open("#{File.dirname(__FILE__)}/source/pages/requirements-generated/mapping.rst", 'w') do |f|
  f.puts 'Test Case Mapping'
  f.puts '================='
  f.puts ''
  f.puts '.. list-table::'
  f.puts '    :width: 100%'
  f.puts '    :widths: 25 25 50'
  f.puts '    :header-rows: 1'
  f.puts ''
  f.puts '    * - Requirements ID'
  f.puts '      - Test Case Location'
  f.puts '      - Test Case Description'

  req_ids.each do |r|
    f.puts "    * - :ref:`#{r} <#{r}>`"
    if ref_reqs.include?(r)
      ref_reqs[r].each_with_index do |data, i|
        f.puts '    * -' if i.positive?
        f.puts "      - #{data['location']}"
        f.puts "      - #{data['description']}"
      end
    else
      f.puts '      - :red:`[missing]`'
      f.puts '      - :red:`[missing]`'
    end
  end
end

# write stats page
File.open("#{File.dirname(__FILE__)}/source/pages/requirements-generated/stats.rst", 'w') do |f|
  f.puts 'Statistics'
  f.puts '=========='
  f.puts ''
  f.puts 'Requirements'
  f.puts '------------'
  f.puts ''
  f.puts '.. list-table::'
  f.puts '    :width: 100%'
  f.puts '    :widths: 50 50'
  f.puts ''
  f.puts '    * - Total number of requirements'
  f.puts "      - #{reqs.length}"
  f.puts '    * - Valid requirements'
  f.puts "      - #{reqs.count { |r| r.status == 'valid' }}"
  f.puts '    * - Covered requirements'
  f.puts "      - #{reqs.count { |r| r.tags.uniq.include?('covered') }}"
  f.puts '    * - Tested requirements'
  f.puts "      - #{reqs.count { |r| r.tags.uniq.include?('tested') }}"
  f.puts '    * - Requirements mapped to test cases'
  f.puts "      - #{req_ids.count { |r| ref_reqs.key?(r) }}"
  f.puts ''
  f.puts 'Test Cases'
  f.puts '----------'
  f.puts ''
  f.puts '.. list-table::'
  f.puts '    :width: 100%'
  f.puts '    :widths: 50 50'
  f.puts ''
  f.puts '    * - Total number of test cases'
  f.puts "      - #{test_cases.length}"
  f.puts '    * - Test cases with valid requirement IDs'
  not_valid = test_cases.select { |_loc, ids| ids.any? { |id| !req_ids.include?(id) } }
  f.puts "      - #{test_cases.length - not_valid.length}"
  not_valid.each_key do |loc|
    f.puts "        |br|:red:`#{loc}`"
  end
  invalid = test_cases.select { |_loc, ids| ids.any? { |id| !req_ids.include?(id) } }
  f.puts '    * - Test cases without invalid requirement IDs'
  f.puts "      - #{test_cases.length - invalid.length}"
  invalid.each do |loc, ids|
    f.puts "        |br|:red:`#{loc}`"
    ids.each do |id|
      f.puts "        |br|- :red:`#{id}`" unless req_ids.include?(id)
    end
  end
end
