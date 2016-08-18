
require 'aws-sdk'
require 'deploy/aws/utils'

class S3Upload

  include InternalUtils

  def initialize(region)
    @creds = load_creds
    @s3 = Aws::S3::Resource.new(region: region,
                                access_key_id: @creds['access_key_id'],
                                secret_access_key: @creds['secret_access_key'],
                                validate_params: true)
  end

  def send(jar, bucket, target, verbose=false)
    puts "Uploading #{jar} \n\t -> #{s3_full_name}...." if verbose

    obj = @s3.bucket(bucket).object(target)
    # generally this throws exceptions on failure
    jarPath = Pathname.new(jar)
    success = obj.upload_file(jarPath)
    # but catch it just in case there was a failure
    raise "Failed to upload #{jarPath} to #{bucket}/#{target}!" unless success
    puts "Uploaded #{jar} to #{file}!" if verbose
    target
  end
  end
end
