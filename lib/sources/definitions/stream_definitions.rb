
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source'

module StreamIngest

  PROPERTIES = [Properties::Kinesis, Properties::Firehose, Properties::Dynamo.new()
                 .withSchemaStore().withIngest().withCreateTable()]

  DEFINITIONS = []
  Source.load(DEFINITIONS, "stream_ingest")

end
