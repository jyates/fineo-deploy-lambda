#!/usr/bin/env ruby

# Property information about the internal apis (e.g. creating a tenant)
class Properties::InternalApi < Properties::Property

  def withCreateSchema
    @opts << ArgOpts.source("mgmt.tenant.lambda",
      "-- NO TENANT LAMBDA FUNCTION SPECIFIED --",
      "internal_apis.create_schema_lambda",
      true)
    self
  end

  def withUsagePlan
    @opts << ArgOpts.source("mgmt.tenant.api.plan",
      "-- NO Target Usage Plan SPECIFIED --",
      "internal_apis.usage_plan",
      true)
    self
  end
end
