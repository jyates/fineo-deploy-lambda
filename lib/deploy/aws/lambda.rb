require 'aws-sdk'
require 'deploy/aws/lambda/lambda'
require 'deploy/aws/utils'

class LambdaAws

  include Lambda
  include InternalUtils

  def initialize(region)
    @creds = load_creds
    @client =  Aws::Lambda::Client.new(
                    region: region,
                    access_key_id: @creds['access_key_id'],
                    secret_access_key: @creds['secret_access_key'],
                    validate_params: true)
  end

  def get_function_state(func)
  end

  def deploy(jar, func)
    # Actually create the lambda function
    didUpload = false
    uploaded = @client.list_functions({})
    encoded = File.binread(jar)
    lambda.functions.each{ |name, function|
      # filter out functions that don't match the expected name
      if should_deploy?(function)
        upload(uploaded.functions, @client, function, encoded)
        didUpload = true
      end
    }

    didUpload
  end
end
