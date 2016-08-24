#!/usr/bin/env ruby

require_relative "properties"

class Properties::Kinesis

  def self.addProps(manager)
     manager.add(ArgOpts.simple("kinesis.url", "kinesis.us-east-1.amazonaws.com", 'Kinesis address - not a URL'),
     ArgOpts.ref("kinesis.parsed", "fineo-parsed-records","streams", 'Parsed Avro record Kinesis stream name'),
     ArgOpts.simple("kinesis.retries", "3", 'Max amount of retries to attempt before failing the request'))
  end
end
