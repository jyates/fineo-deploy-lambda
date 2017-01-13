#!/usr/bin/env ruby

class Properties::Api

  attr_reader :opts
  def initialize()
    @opts = []
  end

  def withSchema
    @opts << ArgOpts.new("api.schema.retries", "1", ->(props){
      parts = "api.schema.properties.retries".split "."
      parts.each{|key|
        props = props[key]
        break if props.nil?
      }
      retries = props
      puts "WARN - api.schema.retries property not found! Using default: 1" if retries.nil?
      retries ||= "1"
      return retries
    })
    self
  end

  def addProps(manager)
    manager.addAll(@opts)
  end

private
end
