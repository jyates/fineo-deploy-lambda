
module SchemaDefinitions
  class FieldMetric < Definition

    def initialize()
      super("metric-field", SchemaDefinitions::Properties)
      function("AddFieldToMetric")
          .withDesc("Add a field to a metric")
          .withMethodHandler("io.fineo.lambda.handle.schema.metric.field.AddFieldToMetric::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
