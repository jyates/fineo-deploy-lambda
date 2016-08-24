#!/usr/bin/env ruby

require_relative "properties"

class Properties::Firehose

  ERROR_FIREHOSES = ->(test_prefix){ "#{test_prefix}failed-records" }

  def self.addProps(manager)
    manager.add(ArgOpts.simple(name("url"), "https://firehose.us-east-1.amazonaws.com", 'Firehose Url'),
      # raw record archiving
      ref("raw.archive", "fineo-raw-archive", "Name of Firehose stream to store all raw records"),
      ref("raw.malformed","fineo-raw-malformed" "Malformed event Firehose stream name"),
      ref("raw.error","fineo-raw-malformed" "Error on write event Firehose stream name"),

      # parsed record - "staged" - params
      ref("staged.archive", "fineo-staged-archive", "Name of Firehose stream to "+
        "archive all staged records"),
      ref("staged.malformed", "fineo-staged-dynamo-error",
        "Malformed Avro event Kinesis Firehose stream name"),
      ref("staged.error", "fineo-staged-commit-failure", "Error on write Avro event Firehose stream name"))
  end

private

  def self.ref(name, default_val, desc)
    ArgOpts.ref(name(name), default_val, "stream", desc)
  end

  def self.name(suffix)
    "firehose.#{suffix}"
  end
end
