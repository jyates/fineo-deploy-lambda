
module StreamDefinitions

  Properties = [Properties::Kinesis,
                Properties::Firehose,
                Properties::Dynamo.new().withSchemaStore().withIngest()]

  DEFINITIONS = []
  SourceLoader.new("Stream", DEFINITIONS, StreamDefinitions).load("stream")
end
