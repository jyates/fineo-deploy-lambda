
require 'yaml'

module InternalUtils

  def load_creds(credentials_file)
    begin
      yaml = YAML.load(File.read(credentials_file))
      return Aws::Credentials.new(yaml['access_key_id'],yaml['secret_access_key'])
    rescue Exception => e
      puts "Could not read credentials file at: #{credentials_file}" unless credentials_file.nil?
      return Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    end
  end
end
