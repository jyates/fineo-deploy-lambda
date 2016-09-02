#!/usr/bin/env ruby
# Deploy the specified jars to AWS

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

# Requires
###########
require 'optparse'
require 'json'
require 'deploy/deploying'
require 'deploy/aws/lambda'

require 'pp'

include Deploying

options = parse(ARGV)
file = File.read(options.source)
jars = JSON.parse(file)

puts "Deploying jars: #{JSON.pretty_generate(jars)}" if options.verbose
defs = find_definitions(jars, options)
lambda = LambdaAws.new(options)
validate_definitions(lambda, defs, options) unless options.config_only
deploy(lambda, defs, options) unless options.dryrun

exit if options.dryrun || !options.verbose
puts "Deployed definitions:"

output = {}
output["lambda"] = {}

defs.each{|d|
  definition = d.def
  set_definition(output, definition, d.path)

  puts d.type
  puts "  -> #{d.name}"
  puts "\t#{d.path}"
  pp(definition) if options.verbose2
}

File.open(options.output,"w") do |f|
  f.write(JSON.pretty_generate(JSON.parse(output.to_json().to_s())))
end
puts "[For next step] Updated lambda jars written to: #{options.output}"
