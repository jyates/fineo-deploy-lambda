
class BatchDefinitions::BatchProcessor < BatchDefinition

  def initialize()
    super("processor",  "BatchProcessor",
      [Properties::Dynamo.new().withCreateBatchManifestTable().withIngest().withSchemaStore(),
       Properties::Firehose.new().staged("archive")
      ],
      ["batch-processing"], "batch.cluster")
  end
end
