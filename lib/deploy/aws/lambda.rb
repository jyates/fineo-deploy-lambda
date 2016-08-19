require 'aws-sdk'
require 'deploy/aws/utils'
require 'pp'

class LambdaAws

  DOES_NOT_EXIST = nil
  include Lambda
  include InternalUtils

  def initialize(options)
    @verbose = options.verbose
    @verbose2 = options.verbose2
    @creds = load_creds(options.credentials)
    @client =  Aws::Lambda::Client.new(
                    region: options.region,
                    access_key_id: @creds['access_key_id'],
                    secret_access_key: @creds['secret_access_key'],
                    validate_params: true)
    @functions = {}
  end

  def get_function_state(func)
    opts = {:function_name => func.name }
    begin
      conf = @client.get_function_configuration(opts)
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      conf = DOES_NOT_EXIST
    end
    @functions[func.name] = conf
    return conf
  end

  def deploy(jar, func)
    jar.sub! "s3://", ""
    parts = jar.split "/"
    bucket = parts.shift
    key = File.join(parts)
    code = {
      s3_bucket: bucket,
      s3_key: key
    }

    conf = @functions[func.name]
    if conf == DOES_NOT_EXIST
      create(func, code)
    else
      update(func, code, conf)
    end
  end

  def update_config(function)
    version = @client.update_function_configuration(function.to_aws_hash()).version
  end

  def promote(definition, stage, version)
    func = definition.func
    begin
      alias = @client.get_alias({function_name: func.name, alias: stage})
      # alias exists, so move it to the new version
      @client.update_alias({function_name: func.name,
                            alias: stage,
                            function_version: version,
                            description: "Updating #{stage} to #{version} from "+
                              "#{alias.function_version"})
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      # alias doesn't exist, so just create it
      @client.create_alias({function_name: func.name,
                              alias: stage,
                              function_version: version,
                              description: "Promoting #{version} to #{stage} - no previous " +
                                "version found for alias"})
    end
  end

private

  def create(function, code)
    puts "Creating function:" if @verbose
    pp(function) if @verbose2

    hash = function.to_aws_hash
    hash[:code] = code
    hash[:publish] = true
    pp hash if @verbose
    @client.create_function(hash).version
  end

  def update(function, code, conf)
    puts "Updating #{function.name}"
    options = {
      function_name: function.name,
      publish: true
    }
    options.merge! code
    @client.update_function_code(options)
    version = update_config(function)
  end
end
