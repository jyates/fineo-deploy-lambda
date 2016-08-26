
require 'sources/type/schema'
require 'sources/definitions/schema_definitions'
require 'sources/definitions/schema_internal_definitions'

class SchemaInternal < SourceType

  def initialize(info)
    super(info["dir"], "schema-lambda", Schema::VERSION)
    set_targets(info["targets"], SchemaInternalDefinitions::DEFINITIONS)
  end
end
