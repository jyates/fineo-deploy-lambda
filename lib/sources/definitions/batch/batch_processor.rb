
class BatchDefinitions::BatchProcessor < BatchDefinition

  def initialize()
    super("processor",  "BatchProcessor",
      [Properties::Dynamo.new().withCreateBatchManifestTable()],
      ["batch-processing"])
  end
end
