
class BatchDefinition < Definition

  attr_reader :parents

  def initialize(name, func_name, properties, parent_path=[])
    super(name, func_name, properties)
    @parents = parent_path
  end
end
