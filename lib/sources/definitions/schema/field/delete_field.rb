
module SchemaDefinitions
  class DeleteField < Definition

    def initialize()
      super("field-delete", "SchemaFieldDelete", SchemaDefinitions::Properties)
    end
  end
end
