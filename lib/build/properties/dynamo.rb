#!/usr/bin/env ruby

class Properties::Dynamo

  attr_reader :opts
  def initialize()
    @opts = []
    @opts << ArgOpts.simple("dynamo.region","us-east-1", 'Region for the table')
    @opts << ArgOpts.simple("dynamo.limit.retries", "3", 'Number of retries to make in the Fineo AWS wrapper')
    @opts << ArgOpts.simple("dynamo.table-manager.cache.timeout", "3600000", 'Milliseconds that a table is retained in the table manager cache between checking if it exists')
  end

  def withSchemaStore
    @opts << ArgOpts.new("dynamo.schema-store", "schema-customer", table_prop?("SchemaStore", "name"))
    self
  end

  def withIngest
    @opts +=[ArgOpts.new("dynamo.ingest.prefix", "customer-ingest", ingest?("prefix")),
              ArgOpts.new("dynamo.ingest.limit.write", "5", ingest?("throughput.write")),
              ArgOpts.new("dynamo.ingest.limit.read", "7", ingest?("throughput.read"))]
    self
  end

  def withCreateBatchManifestTable
    @opts += [ArgOpts.new("dynamo.batch-manifest.limit.write", "1", batch?("throughput.write")),
              ArgOpts.new("dynamo.batch-manifest.limit.read", "1", batch?("throughput.read")),
              ArgOpts.new("dynamo.batch-manifest.table", "batch-manifest", batch?("name"))]
    self
  end

  def withUserInfoMgmt
    @opts +=[
              ArgOpts.new("mgmt.user.dynamo.table", "user-info", user?("name")),
              ArgOpts.new("mgmt.tenant.dynamo.table", "tenant-info", tenant?("name")),
            ]
    self
  end

  def withDeviceMgmt
    @opts +=[
              ArgOpts.new("mgmt.device.dynamo.table", "device-info", table_prop?("DeviceInfo", "name")),
            ]
    self
  end

  def addProps(manager)
    manager.addAll(@opts)
  end

private

  # Helper methods
  # - so we don't need to keep typing table_prop?(table name/reference, property value)

  def ingest?(prop)
    table_prop?("CustomerIngest", prop)
  end

  def batch?(prop)
    table_prop?("BatchManifest", prop)
  end

  def user?(prop)
    table_prop?("UserInfo", prop)
  end

  def tenant?(prop)
    table_prop?("TenantInfo", prop)
  end

  # Actual value of the property is from the the configuration for the given dynamo table name(table ref)'s property.
  # e.g. table_prop?("BatchManifest", "throughput.write") will lookup in the configuration
  #
  # "dynamo": {
  # "tables": {
  #   "BatchManifest": {
  #     "name": "batch-manifest",
  #     "throughput": {
  #       "write": 1,  <--------------- this property
  #       "read": 1
  #     }
  #   }
  # }
  def table_prop?(tableref, prop)
    Proc.new{|props|
      get_table_property_impl(props, tableref, prop)
    }
  end

  def get_table_property_impl(props, tableref, prop)
    ref = props["dynamo"]["tables"][tableref]
    raise "No table reference #{tableref} present!" if ref.nil?

    parts = prop.split "."
    parts.each{|key|
      ref = ref[key]
      return nil if ref.nil?
    }
    ref
  end
end
