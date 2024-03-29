
class SourceType

  attr_reader :targets

  def initialize(dir, source_jar_prefix, version, jar_type="aws")
    @dir = dir
    @prefix = source_jar_prefix
    @version = version
    @jar_type = jar_type
  end

  def set_targets(request, definitions)
    @targets = []
    request.each{|target|
      definitions.each{|poss|
        if poss.matches? target
          @targets << field(poss)
        end
      }
    }
  end

  def field(definition)
    name = definition.name
    props = definition.properties
    field = Target.new(name, @dir, "#{@prefix}-#{@version}-#{@jar_type}.jar")
    props.each{|prop|
      prop.addProps(field)
    }
    field
  end
end
