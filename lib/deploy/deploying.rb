
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

      opts.on("--source FILE", "JSON file defining the sources jars to export. " +
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

      opts.on("--test PROPERTIES", "Do a testing deployment. Specify the testing properties " +
        "file to extract the destination for each lambda function.") do |testing|
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

    puts "Found definitions: #{defs}" if options.verbose2
    defs
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
    if options.testing
      require 'json'
      props = JSON.parse(File.read(options.testing))
      lambda = props["lambda"]
      defs.each{|d|
        definition = d.def
        name = definition.func_name
        s3 = lambda[name]["s3"]
        jar = d.jar
        path = upload.send(jar, s3["bucket"], s3["key"])
        d.path = path
      }
    else
      bucket = options.bucket
      date_dir = Time.now.to_s
      defs.each{|d|
        definition = d.def
        jar = d.jar
        jar_name = File.basename(jar)
        target = File.join(d.type, date_dir, d.name, jar_name)
        path = upload.send(jar, bucket, target)
        d.path = path
        d.version = lambda.deploy(path, definition.func) if options.force_deploy
      }
    end
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
