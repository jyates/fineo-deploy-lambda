#!/usr/bin/env ruby

require_relative "properties"

class Properties::Dynamo

  attr_reader :opts
  def initialize()
    @opts = []
    @opts << ArgOpts.simple("dynamo.region","us-east-1", 'Region for the table')
    @opts << ArgOpts.simple("dynamo.limit.retries", "3", 'Number of retries to make in the Fineo AWS wrapper')
    @opts << ArgOpts.simple("dynamo.table-manager.cache.timeout", "3600000", 'Milliseconds that a table is retained in the table manager cache between checking if it exists')
  end

  def withSchemaStore
    @opts << ArgOpts.new("dynamo.schema-store", "schema-customer",
      table_prop?("SchemaStore", "name"))
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

  def addProps(manager)
    manager.addAll(@opts)
  end

private

  def ingest?(prop)
    table_prop?("CustomerIngest", prop)
  end

  def batch?(prop)
    table_prop?("BatchManifest", prop)
  end

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
