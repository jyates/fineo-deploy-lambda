
require 'sources/definitions/batch_definitions'

class Batch < SourceType

  VERSION = "2.0-SNAPSHOT"

  def initialize(info)
    super(info["dir"], ["batch-processing", "sns-handler", "lambda-emr-launch"], VERSION)
    set_targets(info["targets"], BatchDefinitions::DEFINITIONS)
  end

  def field(definition)
    name = definition.name
    props = definition.properties
    jar = "#{definition.parents.last}-#{@version}-#{@jar_type}.jar"
    dir = File.join(@dir, definition.parents, "target")
    if File.exist? File.join(dir, jar)
      field = Target.new(name, dir, jar)
    else
      field = Target.new(name, @dir, jar)
    end
    props.each{|prop|
      prop.addProps(field)
    }
    field
  end
end
