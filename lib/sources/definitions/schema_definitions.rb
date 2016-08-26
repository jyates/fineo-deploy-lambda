
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source_loader'

module SchemaDefinitions

  Properties = [Properties::Dynamo.new().withSchemaStore()]
  DEFINITIONS = []

  loader = SourceLoader.new("Schema", DEFINITIONS, SchemaDefinitions)
  loader.load("schema")
  loader.load("schema/metric")
  loader.load("schema/field")
end
