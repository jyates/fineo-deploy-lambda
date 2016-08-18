
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source_loader'

module SchemaDefinitions

  Properties = [Properties::Dynamo.new().withSchemaStore().withCreateTable()]
  DEFINITIONS = []

  loader = SourceLoader.new(DEFINITIONS, SchemaDefinitions)
  loader.load("schema")
  loader.load("schema/metric")
  loader.load("schema/field")
end
