
require 'util/files'
require 'source_handler'
require 'ostruct'
require 'optparse'
require 'sources'
require 'json'

module Building

  TEST_KEY = "integration.test.prefix"

  def parse(args)
    options = OpenStruct.new
    options.source = "input.json"
    options.output = "build.json"
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

      opts.on("--properties-dir DIRECTORY", "Directory containing properties for all the stacks. Stack properties expected to be named: '<stack>.json' in the directory") do |dir|
        options.props_dir = dir
      end

      opts.on("--props PROPERTIES_FILE", "Json file containing function properties.") do |props|
        options.props = props
      end

      opts.on("--test", "If we are running a test. Properties file should be a test file, "+
        "and thus contain the output locations for the all the necessary jars") do |v|
        options.testing = true
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
    end.parse!(args)
    return options
  end

  def load_properties(name, options)
    unless options.props.nil?
      properties = JSON.parse(File.read(options.props))
    else
      # find the correct properties fiel in the directory
      file = File.join(options.props_dir, "#{name}.json")
      raise "Missing properties file: #{file}!" unless File.exists? file
      properties = JSON.parse(File.read(file))
    end
    testing = get_property(properties, TEST_KEY)
    raise "Testing property (#{TEST_KEY}) not set in properties!" if !testing && options.testing
    raise "Testing NOT specified, but found testing marker (#{TEST_KEY})!" if testing && ! options.testing
    properties
  end

private

  def get_property(hash, dot_separated_value)
    value = dot_separated_value.split "."
    while !value.empty? && !hash[value[0]].nil?
      hash = hash[value.shift]
    end
    return value.empty? ? hash : nil
  end
end
