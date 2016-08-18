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

options = OpenStruct.new
options.region = 'us-east-1'
options.bucket =  'lambda.fineo.io/jars'

OptionParser.new do |opts|
  opts.banner = "Usage: deploy-lambda.rb [options]"
  opts.separator "Deploy AWS Lambda functions"
  opts.separator "  Options:"

  opts.on("--source FILE", "JSON file defining the sources jars to export") do |source|
    options.source = source
  end

  opts.on('-c', '--credentials FILE', "Location of the credentials FILE to use.") do |s|
    @options.credentials = s
  end

  opts.on('-r', '--region REGIONNAME', "Specify the region. Default: #{@options.region}") do |name|
    @options.region = name
  end

  opts.on("-b", '--bucket BUCKET', "Name of the s3 bucket to deploy the jars. Default: "+
    "#{@options.bucket}") do |bucket|
    @options.bucket = bucket
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
defs = find_definitions(jars)
validate_states(defs)
deploy(defs, options.bucket) unless options.dryrun
