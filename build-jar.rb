#!/usr/bin/env ruby

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

# Constants
############
$PROP_FILE = "fineo-lambda.properties"

# Main
#######
require 'building'
include SourceHandler
include Building

options = parse(ARGV)

# Array of hashes
file = File.read(options.source)
sources = JSON.parse(file)
# ensure its an array
sources = [sources] if sources.class == Hash
managers = {}

sources.each{|entry|
  source = entry.shift
  name = source[0]
  info = source[1]["info"]
  builder = SOURCES[name]
  raise "No builder found for '#{name}'" if builder.nil?
  managers[name] = builder.call(info)
}

managers.each{|name, source|
  properties = load_properties(name, options)
  build_properties(source, properties, options.testing)
}

managers.each{|name, source|
  print_target_properties(source, options.verbose2)
}

# Done if we are dry-running
exit if options.dryrun

puts "Updating jars..."
tmp = "tmp/open"
out = "tmp/out_#{Time.now.to_s.gsub(' ', '')}_#{Random.new().rand(1000000)}"
create_tmp tmp
create_tmp out

types = []
info = {
  "types" => types
}

managers.each{|source_name, source|
  name = source.class.name
  types << name
  source_info = update_jars(tmp, out, source, options.verbose)
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
  puts "[For next step] Updated jars in json file: '#{options.out}'"
end
