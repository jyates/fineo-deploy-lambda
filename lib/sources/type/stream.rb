
require 'sources/definitions/stream_definitions'

class Stream < SourceType

  VERSION = "2.0-SNAPSHOT"

  def initialize(info)
    super(info["dir"], "stream-processing", VERSION)
    set_targets(info["targets"], StreamDefinitions::DEFINITIONS)
  end
end
