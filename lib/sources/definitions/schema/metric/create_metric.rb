
module SchemaDefinitions
  class CreateMetric < Definition

    def initialize()
      super("metric-create", SchemaDefinitions::Properties)
      @function_def =
        Lambda::Func.new("CreateMetric")
          .withDesc("Create a metric type")
          .withMethodHandler("io.fineo.lambda.handle.schema.metric.create.CreateMetric::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
