
module SchemaDefinitions
  class DeleteMetric < Definition

    def initialize()
      super("metric-delete", SchemaDefinitions::Properties)
      function("DeleteMetric")
          .withDesc("Delete a metric type")
          .withMethodHandler("io.fineo.lambda.handle.schema.metric.delete.DeleteMetric::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
