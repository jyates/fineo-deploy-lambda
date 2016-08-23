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

include Deploying

options = parse(ARGV)
file = File.read(options.source)
jars = JSON.parse(file)

puts "Deploying jars: #{jars}" if options.verbose
defs = find_definitions(jars, options)
lambda = LambdaAws.new(options)
validate_definitions(lambda, defs) unless options.config_only
deploy(lambda, defs, options) unless options.dryrun

exit unless options.verbose
puts "Deployed definitions:"
defs.each{|d|
  puts d.type
  puts "  -> #{d.name}"
  definition = d.def
  func = definition.func
  puts "\tLambda Properties"
  puts "\t  name:    #{func.name}"
  puts "\t  timeout: #{func.timeout}"
  puts "\t  memory:  #{func.memory}"
  puts "\t  handler: #{func.handler}"
  next unless options.verbose2
  puts
  puts "\tFunction Properties"
  definition.properties.each{|prop|
    prop.opts.each{|opt|
      puts "\t  #{opt.key} => #{opt.value} - #{opt.desc}"
    }
  }
}
