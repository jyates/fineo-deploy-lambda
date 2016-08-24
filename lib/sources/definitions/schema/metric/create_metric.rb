
module SchemaDefinitions
  class CreateMetric < Definition

    def initialize()
      super("metric-create", "SchemaMetricCreate", SchemaDefinitions::Properties)
    end
  end
end
