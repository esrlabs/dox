require 'dim/loader'

l = Dim::Loader.new
l.load(input_filenames: "#{File.dirname(__FILE__)}/test/config.dim")

mods = l.requirements.values.map(&:document).uniq
reqs = l.requirements.values.select do |r|
  r.review_status != 'rejected' && r.type == 'requirement'
end

puts "Number of requirements: #{reqs.length}"

puts "\nNumber requirements with (developer == CompanyName) and (outgoing references and/or verification_methods) per module:"
reqs_company = reqs.select { |r| r.developer.include?('CompanyName') }
mods.each do |m|
  reqs_company_module = reqs_company.select { |r| r.document == m }
  reqs_matching = reqs_company_module.reject { |r| r.verification_methods == ['none'] }
  puts "#{m}: #{reqs_matching.length} of #{reqs_company_module.length}"
  puts(reqs_matching.map { |r| "- #{r.id}" })
end
