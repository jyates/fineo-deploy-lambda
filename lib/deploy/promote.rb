
require 'sources'
require 'optargs'
require 'ostruct'

module Promote
  def parse(args)
    options = OpenStruct.new

    OptionParser.new do |opts|
      opts.banner = "Usage: deploy-lambda.rb [options]"
      opts.separator "Promote AWS Lambda functions to a given alias"
      opts.separator "  Options:"

      opts.on("--type NAME", "Type of function, e.g. 'schema' or 'stream'") do |type|
        options.type = type
      end

      opts.on("--function NAME", "Name of the function to promote") do |name|
        options.function = name
      end

      opts.on("--stage NAME", "Name of the stage to which to promote the function") do |stage|
        options.stage = stage
      end

      opts.on('-c', '--credentials FILE', "Location of the credentials FILE to use.") do |s|
        options.credentials = s
      end

      opts.on("-v", "--verbose", "Verbose output") do |v|
        options.verbose = true
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(args)
    options
  end
end
