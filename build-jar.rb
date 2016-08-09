#!/usr/bin/env ruby

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

# Constants
############
$PROP_FILE = "fineo-lambda.properties"

# Requires
############
require 'util/files'
require 'source_handler'
require 'ostruct'

# Main
#######
include SourceHandler

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: template.rb [options]"
  opts.separator "Liquid based templating for the Fineo API"
  opts.separator "  Options:"

  opts.on("--dry-run", "Enable dry run") do |v|
    options.dryrun = v
  end

  opts.on("--testing [PREFIX]", "Build the parameters for a testing run" do |v|
    v = "deploy-testing-#{Random.new(100000)}" if v.nil?
    options.testing = v
  end

  opts.on("-v", "--verbose", "Verbose output") do |v|
    options.verbose = true
  end

  opts.on("--vv", "Extra Verbose output") do |v|
    options.verbose = true
    options.verbose2 = true
  end
end.parse!(ARGV)

# Rest of the parameters are managed through environment variables
schema_source = ENV['SCHEMA_SOURCE']
ingest_source = ENV['INGEST_SOURCE']

ingest_targets = {
  :raw => ENV['Ingest_Raw'],
  :write => ENV['Ingest_Write'],
  :clean_dynamo => ENV['Ingest_CleanDynamo']
}

schema_targets = {
  :org => ENV['Schema_Org_Create'],
  :metric_create => ENV['Schema_Metric_Create'],
  :metric_delete => ENV['Schema_Metric_Delete'],
  :metric_update => ENV['Schema_Metric_Update'],
  :metric_field  => ENV['Schema_Metric_Field'],
  :field_delete  => ENV['Schema_Field_Delete'],
  :field_update  => ENV['Schema_Field_Update']
}

schema = Schema.new(schema_source, schema_targets)
ingest = Ingest.new(ingest_source, ingest_targets)
sources = [schema, ingest]
sources.each{|source|
  build_properties(source, options.testing, ARGV)
}

sources.each{|source|
  print_target_properties(source, options.verbose2)
}

# Done if we are dry-running
exit if options.dryrun.nil?

sources.each{|source|
  update_jars(source, options.verbose)
}
