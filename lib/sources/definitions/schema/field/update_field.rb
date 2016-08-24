
module SchemaDefinitions
  class UpdateField < Definition

    def initialize()
      super("field-update", "SchemaFieldUpdate", SchemaDefinitions::Properties)
    end
  end
end
