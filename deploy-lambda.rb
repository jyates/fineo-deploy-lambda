#!/usr/bin/env ruby
# Deploy the specified jars to AWS

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

# Requires
###########
require 'json'

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: deploy-lambda.rb [options]"
  opts.separator "Deploy AWS Lambda functions"
  opts.separator "  Options:"

  opts.on("--source FILE", "JSON file defining the sources jars to export") do |source|
    options.source = source
  end

  opts.on("--dry-run", "Enable dry run") do |v|
    options.dryrun = true
  end

  opts.on("-v", "--verbose", "Verbose output") do |v|
    options.verbose = true
  end

  opts.on("--vv", "Extra Verbose output") do |v|
    options.verbose = true
    options.verbose2 = true
  end
end.parse!(ARGV)

file = File.read(options.source)
jars = JSON.parse(file)

puts "Deploying jars: #{jars}" if options.verbose

