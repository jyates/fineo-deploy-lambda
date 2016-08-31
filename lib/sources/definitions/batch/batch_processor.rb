
class BatchDefinitions::BatchProcessor < BatchDefinition

  def initialize()
    super("processor",  "BatchProcessor",
      [Properties::Dynamo.new().withCreateBatchManifestTable().withIngest().withSchemaStore()],
      ["batch-processing"], "batch.cluster")
  end
end
