
require 'sources/definitions/schema_definitions'

class Schema < SourceType

  VERSION = "2.0-SNAPSHOT"

  def initialize(info)
    super(info["dir"], "schema-lambda", VERSION)
    set_targets(info["targets"], SchemaDefinitions::DEFINITIONS)
  end
end
