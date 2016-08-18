
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source_loader'

module StreamDefinitions

  Properties = [Properties::Kinesis, Properties::Firehose, Properties::Dynamo.new()
                 .withSchemaStore().withIngest().withCreateTable()]

  DEFINITIONS = []
  SourceLoader.new(DEFINITIONS, StreamDefinitions).load("stream_ingest")
end
