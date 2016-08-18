
class PropertyModule

  attr_reader :targets

  def initialize(dir, prefix, version, jar_type="aws")
    @dir = dir
    @prefix = prefix
    @version = version
    @jar_type = jar_type
  end

  def set_targets(request, definitions)
    @targets = []
    request.each{|target|
      definitions.each{|poss|
        if poss.matches? target
          @targets << field(poss)
          break
        end
      }
    }
  end

  def field(definition)
    field?(definition.name, definition.properties)
  end

  def field? (name, props)
    field = Target.new(name, @dir, "#{@prefix}-#{@version}-#{@jar_type}.jar")
    props.each{|prop|
      prop.addProps(field)
    }
    field
  end
end
