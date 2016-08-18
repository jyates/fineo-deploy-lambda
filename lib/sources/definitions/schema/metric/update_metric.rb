
module SchemaDefinitions
  class UpdateMetric < Definition

    def initialize()
      super("metric-update", SchemaDefinitions::Properties)
      function("UpdateMetric")
          .withDesc("Update a metric schema")
          .withMethodHandler("io.fineo.lambda.handle.schema.metric.update.UpdateMetric::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
