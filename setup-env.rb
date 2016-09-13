#!/usr/bin/env ruby
# Convert  environment variables into json format output dumped to the console. Its up to the caller
# to sort the output appropriately and then use that as input to build-jar.rb

require 'json'

def simplify(hash)
  hash.select{|k,v|
    !v.nil?
  }
end

def append(arr, env_name, name)
  value = ENV[env_name]
  arr << name unless value.nil?
end

def as_input(input, name, dir_key)
  return nil if input.empty?
  dir = ENV[dir_key]
  raise "No source directory specified for #{name} => ENV[#{dir_key}]!" if dir.nil?
  info = {"dir" => dir, "targets" => input}
  {name => { "info" => info}}
end

params = []

ingest = []
append(ingest,'Ingest_External', "ingest")
append(ingest,'Ingest_Raw', "raw")
append(ingest,'Ingest_Write', "storage")
append(ingest,'Ingest_CleanDynamo', "clean")

input = as_input(ingest, "stream", 'Ingest_Source_Dir')
params << input unless input.nil?

schema = []
append(schema, 'Schema_Org_Create', "create")
metric = []
append(metric, 'Schema_Metric_Create', "create")
append(metric, 'Schema_Metric_Update', "update")
append(metric, 'Schema_Metric_Delete', "delete")
append(metric, 'Schema_Metric_Field', "field")
schema << {"metric" => metric} unless metric.empty?
field = []
append(field, 'Schema_Field_Delete', "delete")
append(field, 'Schema_Field_Update', "update")
schema << {"field" => field} unless field.empty?

input = as_input(schema, "schema", 'Schema_Source_Dir')
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

puts "#{params.to_json}"
