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
require 'sources'
require 'json'

# Main
#######
include SourceHandler

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: template.rb [options]"
  opts.separator "Liquid based templating for the Fineo API"
  opts.separator "  Options:"

  opts.on("--source FILE", "JSON file defining the sources we will transform") do |source|
    options.source = source
  end

  opts.on("--dry-run", "Enable dry run") do |v|
    options.dryrun = v
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
end.parse!(ARGV)

# Array of hashes
file = File.read(options.source)
sources = JSON.parse(file)

managers = []
sources.each{|source|
  name = source["source"]
  info = source["info"]
  managers << SOURCES[name].call(info)
}

common_props = {}
managers.each{|source|
  common_props.merge!(build_properties(source, options.testing, ARGV))
}

managers.each{|source|
  print_target_properties(source, common_props, options.verbose2)
}

# Done if we are dry-running
exit if options.dryrun.nil?

tmp = "tmp"
Dir.mkdir(tmp)
managers.each{|source|
  update_jars(tmp, source, common_props, options.verbose)
}
