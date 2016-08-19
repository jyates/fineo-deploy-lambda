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
require 'optparse'
require 'sources'
require 'json'

# Main
#######
include SourceHandler

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: build-jar.rb [options]"
  opts.separator "Build lambda function jars"
  opts.separator "  Options:"

  opts.on("--source FILE", "JSON file defining the sources we will transform") do |source|
    options.source = source
  end

  opts.on("--output FILE", "JSON file with the list of updated jars") do |out|
    options.out = out
  end

  opts.on("--dry-run", "Enable dry run") do |v|
    options.dryrun = true
  end

  opts.on("--testing [PREFIX]", "Build the parameters for a testing run") do |v|
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

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!(ARGV)

# Array of hashes
file = File.read(options.source)
sources = JSON.parse(file)
# ensure its an array
sources = [sources] if sources.class == Hash
managers = []

sources.each{|entry|
  source = entry.shift
  name = source[0]
  info = source[1]["info"]
  managers << SOURCES[name].call(info)
}

common_props = {}
managers.each{|source|
  common_props.merge! build_properties(source, options.testing, ARGV)
}

managers.each{|source|
  print_target_properties(source, common_props, options.verbose2)
}

# Done if we are dry-running
exit if options.dryrun

puts "Updating jars..."
tmp = "tmp/open"
out = "tmp/out"
create_tmp tmp
create_tmp out

types = []
info = {
  "types" => types
}

managers.each{|source|
  name = source.class.name
  types << name
  source_info = update_jars(tmp, out, source, common_props, options.verbose)
  info[name] = source_info
}

if options.out.nil?
  require 'pp'
  puts "Final jars available at:"
  pp(info)
else
  File.open(options.out,"w") do |f|
    f.write(info.to_json)
  end
  puts "Updated jars in json file: '#{options.out}'"
end
