
require 'sources'
require 'ostruct'
require 'deploy/aws/s3_upload'

module Deploying

  def parse(args)
    options = OpenStruct.new
    options.region = 'us-east-1'
    options.bucket =  'deploy.fineo.io/lambda'
    options.source = "build.json"
    options.output = "updates.json"

    OptionParser.new do |opts|
      opts.banner = "Usage: deploy-lambda.rb [options]"
      opts.separator "Deploy AWS Lambda functions"
      opts.separator "  Options:"

      opts.on("--source FILE", "JSON file defining the source jars to export. " +
        "Default: #{options.source}") do |source|
        options.source = source
      end

      opts.on("--output FILE", "JSON file to write the updated locations for each function. " +
        "Default: #{options.output}") do |source|
        options.output = source
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

      opts.on("--test PROPERTIES", "Do a test deployment. Specify the testing properties file or directory of stack properties" +
        " from which extract the destination for each lambda function.") do |testing|
        options.testing = testing
      end

      opts.on("--dry-run", "Enable dry run") do |v|
        options.dryrun = true
      end

      opts.on("--really-force-deploy-lambda-functions", "You really really want to force "+
        "deployment of lambda functions from the command line/ci, instead of doing it the right "+
        "way through an updated change set in cloudformation.") do |force|
        puts "  --------  WARNING --------- "
        puts " This should only be used in extreme circumstances to force deployment of lambda "+
        "functions. Instead, you should just deploy the jars and update a cloudformation template."
        puts " *** You have bee warned *** "
        puts "  --------  WARNING --------- "
        options.force_deploy = true
      end

      opts.on("--update-config-only", "Only update the configuration of the specified functions") do |v|
        options.config_only = true
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

    defs
  end

  def definition_stack_name?(definition)
    parts = definition.type.split /(?=[A-Z])/
    parts.map!{|f| f.downcase}
    parts.join "-"
  end

  # ensure that the current properties associated with the definition match those, if the
  # function has already been deployed
  def validate_definitions(lambda, defs, options)
    return unless options.force_deploy

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

    upload = S3Upload.new(options)

    # using the testing options for the lambda function
    unless options.testing
      bucket = options.bucket
      date_dir = Time.now.to_s.gsub(" ", "_")
      defs.each{|d|
        definition = d.def
        jar = d.jar
        jar_name = File.basename(jar)
        target = File.join(d.type, d.name, date_dir, jar_name)
        path = upload.send(jar, bucket, target)
        d.path = path
        d.version = lambda.deploy(path, definition.func) if options.force_deploy
      }
      return
    end

    # Testing
    require 'json'
    if File.file?(options.testing)
      # single file specified, just load the definition as a single function
      properties = JSON.parse(File.read(options.testing))
      defs.each{|d|
        deploy_test_function(upload, d, properties)
      }
    else
      defs.each{|d|
        # its a directory and we need to load the stack properties for each definition (lazy, but easier to verify)
        stack_name = definition_stack_name?(d)
        file = File.join(options.testing, "#{stack_name}.json")
        properties = JSON.parse(File.read(file))
        deploy_test_function(upload, d, properties)
      }
    end
  end

  def set_definition(output, definition, path)
    func_def = output
    definition.config_key.split(".").each{|key|
      nextHash = func_def[key]
      if nextHash.nil?
        nextHash = {}
        func_def[key] = nextHash
      end
      func_def = nextHash
    }

    s3 = {}
    func_def["s3"] = s3
    path = path.sub("s3://", "")
    parts = path.split "/"
    s3["bucket"] = parts.shift
    s3["key"] = File.join(parts)
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

  def deploy_test_function(upload, full_definition, properties)
    definition = full_definition.def
    name = definition.func_name
    lambda = properties
    definition.config_key.split(".").each{|part|
      lambda = lambda[part]
      break if lambda.nil?
    }
    raise "No property found for #{definition.config_key} in properties!" if lambda.nil?
    s3 = lambda["s3"]
    jar = full_definition.jar
    path = upload.send(jar, s3["bucket"], s3["key"])
    full_definition.path = path
  end
end
