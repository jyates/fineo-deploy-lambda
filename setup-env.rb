#!/usr/bin/env ruby
# Convert  environment variables into json format output dumped to the console. Its up to the caller
# to sort the output appropriately and then use that as input to build-jar.rb

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

require 'json'
require 'optparse'
require 'ostruct'

@options  = OpenStruct.new(all: false)
OptionParser.new do |opts|
  opts.banner = "Usage: setup-env.rb [options]"
  opts.separator "Setup the input file from environment variables for deploying jars"
  opts.separator "  Options:"

  opts.on("--deploy-all", "Ignore environment variables and just deploy all the jars. Should be used for == TESTING ==") do |t|
      @options.all = true
  end
end.parse!(ARGV)

require 'environment_settings'
include EnvironmentSettings

params = []

ingest = []
append(ingest,'Ingest_External', "ingest")
append(ingest,'Ingest_Raw', "raw")
append(ingest,'Ingest_Write', "storage")
append(ingest,'Ingest_CleanDynamo', "clean")

input = as_input(ingest, "stream", 'Ingest_Source_Dir')
params << input unless input.nil?

schema = []
append(schema, 'Schema_Org_Update', "org")
append(schema, 'Schema_Metrics_Read', "metrics")
metric = []
# this creates a 'name key' of the form "metric-create"
append(metric, 'Schema_Metric_Create', "create")
append(metric, 'Schema_Metric_Read', "read")
append(metric, 'Schema_Metric_Update', "update")
append(metric, 'Schema_Metric_Delete', "delete")
schema << {"metric" => metric} unless metric.empty?
field = []
append(field, 'Schema_Field_Create', "create")
append(field, 'Schema_Field_Read', "read")
append(field, 'Schema_Field_Update', "update")
schema << {"field" => field} unless field.empty?

input = as_input(schema, "schema", 'Schema_Source_Dir')
params << input unless input.nil?

schema_internal = []
append(schema_internal, 'Internal_Schema_Org_Create', "org")
input = as_input(schema_internal, "schema-internal", 'Schema_Source_Dir')
params << input unless input.nil?

batch = []
sns = []
append(sns,'Batch_Sns_S3_Local', "local")
append(sns,'Batch_Sns_S3_Remote', "remote")
batch << {"sns" => sns} unless sns.empty?

append(batch,'Batch_Spark_Processor', "processor")
append(batch,'Batch_Launch_EMR_Cluster', "launchemr")
input = as_input(batch, "batch", 'Batch_Processing_Parent_Dir')
params << input unless input.nil?

puts "#{JSON.pretty_generate(params)}"
