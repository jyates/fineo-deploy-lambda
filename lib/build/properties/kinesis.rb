#!/usr/bin/env ruby

class Properties::Kinesis

  def self.addProps(manager)
     manager.add(
     ArgOpts.ref("kinesis.ingest", "fineo-customer-ingest", "streams", 'Raw event ingest stream'),
     ArgOpts.ref("kinesis.parsed", "fineo-parsed-records", "streams", 'Parsed Avro record Kinesis stream name'),
     ArgOpts.property_ref("kinesis.url", "kinesis.us-east-1.amazonaws.com", 'Kinesis address - not a URL'),
     ArgOpts.property_ref("kinesis.retries", "3", 'Max amount of retries to attempt before failing the request'))
  end
end
