require 'sources/definitions/meta_definitions'

class Meta < SourceType

  VERSION = "1.0-SNAPSHOT"

  def initialize(info)
    super(info["dir"], "mgmt-lambda", VERSION)
    set_targets(info["targets"], MetaDefinitions::DEFINITIONS)
  end
end
