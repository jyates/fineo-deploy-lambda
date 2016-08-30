
class BatchDefinition < Definition

  attr_reader :parents

  def initialize(name, func_name, properties, parent_path, key=nil)
    super(name, func_name, properties, key)
    @parents = parent_path
  end
end
