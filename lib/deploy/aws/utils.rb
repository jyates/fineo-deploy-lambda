
require 'yaml'

module InternalUtils

  def load_creds(credentials_file)
    begin
      creds = YAML.load(File.read(credentials_file))
    rescue Exception => e
      puts "Could not read credentials file at: #{credentials_file}"
      raise e
    end
    creds
  end
end
