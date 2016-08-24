
module SchemaDefinitions
  class FieldMetric < Definition

    def initialize()
      super("metric-field",  "SchemaFieldCreate", SchemaDefinitions::Properties)
    end
  end
end
