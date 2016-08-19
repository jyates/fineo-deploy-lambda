
require 'sources'
require 'ostruct'
require 'deploy/aws/s3_upload'

module Deploying

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
      lambda.deploy(path, definition.func)
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
