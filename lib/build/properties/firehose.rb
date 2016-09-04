#!/usr/bin/env ruby

require_relative "properties"

class Properties::Firehose

  def self.addProps(manager)
    Firehose.new().all_raw().all_staged().addProps(manager)
  end

  def initialize()
    @opts = [ArgOpts.simple(name("url"), "https://firehose.us-east-1.amazonaws.com",
      'Firehose Url')]
  end

  def all_raw
    raw("archive", "malformed", "error")
    self
  end

  def all_staged
    staged("archive", "malformed", "error")
    self
  end

  def raw(*names)
    names.each{|name|
      addStage("raw", name)
    }
    self
  end

  def staged(*names)
    names.each{|name|
      addStage("staged", name)
    }
    self
  end

  def addProps(manager)
    manager.addAll(@opts)
  end

private

  def ref(name, default_val, desc)
    ArgOpts.ref(name(name), default_val, "streams", desc)
  end

  def name(suffix)
    "firehose.#{suffix}"
  end

  def addStage(stage, name)
    @opts << ref("#{stage}.#{name}", "fineo-#{stage}-#{name}", "Firehose: #{stage} - #{name}")
  end
end
