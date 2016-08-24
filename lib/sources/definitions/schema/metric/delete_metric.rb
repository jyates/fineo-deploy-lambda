
module SchemaDefinitions
  class DeleteMetric < Definition

    def initialize()
      super("metric-delete", "SchemaMetricDelete", SchemaDefinitions::Properties)
    end
  end
end
