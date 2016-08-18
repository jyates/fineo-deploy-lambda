
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source'

module SchemaDefinitions

  Properties = [Properties::Dynamo.new().withSchemaStore().withCreateTable()]
  DEFINITIONS = []

  Source.load(DEFINITIONS, "schema")
  Source.load(DEFINITIONS, "schema/metric")
  Source.load(DEFINITIONS, "schema/field")
end
