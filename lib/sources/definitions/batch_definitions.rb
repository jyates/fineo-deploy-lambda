
require_relative 'batch/util/batch_definition'

module BatchDefinitions

  Manifest_Properties = [Properties::Dynamo.new().withCreateBatchManifestTable()]

  DEFINITIONS = []
  SourceLoader.new("Batch", DEFINITIONS, BatchDefinitions).load("batch")
end
