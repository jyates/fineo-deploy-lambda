
require 'sources'
require 'ostruct'
require 'deploy/aws/s3_upload'

module Deploying

  def parse(args)
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
        options.credentials = s
      end

      opts.on('-r', '--region REGIONNAME', "Specify the region. Default: #{options.region}") do |name|
        options.region = name
      end

      opts.on("-b", '--bucket BUCKET', "Name of the s3 bucket to deploy the jars. Default: "+
        "#{options.bucket}") do |bucket|
        options.bucket = bucket
      end

      opts.on("--update-config-only", "Only update the configuration of the specified functions") do |v|
        options.config_only = true
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

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(args)
    options
  end

  def find_definitions(jars, options)
    defs = []
    jars["types"].each{|type|
      d = Definitions[type]
      jars[type].each{|name, jar|
        found = d.find{|inst|
          inst.name == name
        }
        next if found.nil?
        definition = OpenStruct.new
        definition.type = type
        definition.name = name
        definition.def = found
        definition.jar = jar
        defs << definition
      }
    }

    puts "Found definitions: #{defs}" if options.verbose2
    defs
  end

  # ensure that the current properties associated with the definition match those, if the
  # function has already been deployed
  def validate_definitions(lambda, defs)
    defs.each{|d|
      definition = d.def
      func = definition.func
      state = lambda.get_function_state(func)
      # haven't deployed this function yet
      next if state == LambdaAws::DOES_NOT_EXIST
      validate_state(state, definition)
    }
  end

  def deploy(lambda, defs, options)
    if options.config_only
      update_config(lambda, defs)
      return
    end

    bucket = options.bucket
    date_dir = Time.now.to_s
    upload = S3Upload.new(options)
    defs.each{|d|
      definition = d.def
      jar = d.jar
      jar_name = File.basename(jar)
      target = File.join(d.type, date_dir, d.name, jar_name)
      path = upload.send(jar, bucket, target)
      d.version = lambda.deploy(path, definition.func)
    }
  end

private

  def update_config(lambda, defs)
    defs.each{|d|
      puts "Updating config for #{d.type} - #{d.name}"
      lambda.update_config(d.def.func)
    }
  end

  def validate_state(state, definition)
    func = definition.func
    verify(definition.name, "memory", func.memory, state.memory_size)
    verify(definition.name, "timeout", func.timeout, state.timeout)
    verify(definition.name, "role", func.role, state.role)
    verify(definition.name, "handler", func.handler, state.handler)
  end

  def verify(func_name, name, expected, actual)
    raise "#{func_name}:: Mismatch for #{name}. Expected: #{expected}. Actual: #{actual}" unless
      expected == actual
  end
end
