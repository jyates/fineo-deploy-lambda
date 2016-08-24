
require 'util/files'
require 'source_handler'
require 'ostruct'
require 'optparse'
require 'sources'
require 'json'

module Building

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
    end.parse!(args)
    options
  end

end
