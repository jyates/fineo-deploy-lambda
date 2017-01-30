#!/usr/bin/env ruby

# Property information about the internal apis (e.g. creating a tenant)
class Properties::InternalApi < Properties::Property

  def withCreateSchema
    @opts << ArgOpts.new("mgmt.tenant.lambda", "-- NO TENANT LAMBDA FUNCTION SPECIFIED --",
      ->(props){
      parts = "internal_apis.properties.create_schema_lambda".split(".")
      parts.each{|key|
        props = props[key]
        break if props.nil?
      }
      return props;
    })
    self
  end
end
