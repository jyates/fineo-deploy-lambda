
require 'sources'
require 'ostruct'
require 'deploy/lambda'

module Deploying

  def find_definitions(jars)
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
      next if state == NOT_PRESENT
      validate_state(state, definition)
    }
  end

  def deploy(lambda, defs, bucket)
    date_dir = Time.now
    upload = S3Upload.new(options.region)
    defs.each{|d|
      definition = d.def
      jar = d.jar
      jar_name = File.basename(jar)
      target = File.join(d.type, date_dir, name, jar_name)
      path = upload.send(jar, bucket, target, options.verbose)
      lambda.deploy(path, definition.func)
    }
  end

private

  def update_lambda(path, func)
  end

  def validate_state(state, func)
    verify(definition.name, "memory" func.memory, state.memory)
    verify(definition.name, "timeout" func.timeout, state.timeout)
    verify(definition.name, "role" func.role, state.role)
    verify(definition.name, "handler" func.handler, state.handler)
  end

  def verify(func_name, name, expected, actual)
    raise "#{func_name}:: Mismatch for #{name}. Expected: #{expected}. Actual: #{actual}" unless
      expected == actual
  end
end
