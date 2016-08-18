
class StreamIngest

  VERSION = "2.0-SNAPSHOT"

  def initialize(info)
    super(info["dir"], "stream-processing", VERSION)
    set_targets(info["targets"], SchemaDefinitions::DEFINITIONS)
  end
end
