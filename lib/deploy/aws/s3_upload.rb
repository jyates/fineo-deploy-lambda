
require 'aws-sdk'
require 'deploy/aws/utils'

class S3Upload

  include InternalUtils

  def initialize(options)
    @creds = load_creds(options.credentials)
    @s3 = Aws::S3::Resource.new(credentials: @creds,
                                validate_params: true,
                                log_level: :debug)
    @verbose = options.verbose
  end

  def send(jar, bucket, target)
    jar = File.absolute_path(jar)
    s3_full_name = File.join("s3://", bucket, target)
    puts "Uploading #{jar} \n\t -> #{s3_full_name}...." if @verbose

    # fix the bucket name/prefix to match the s3 format
    parts = bucket.split "/"
    bucket = parts.shift
    target = File.join(parts, target) unless parts.empty?
    success = @s3.bucket(bucket).object(target).upload_file(jar)
    # catch just in case there was a failure
    raise "Failed to upload #{jarPath} to #{s3_full_name}!" unless success
    s3_full_name
  end
end
