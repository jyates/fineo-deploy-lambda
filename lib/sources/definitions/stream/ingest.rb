
class StreamDefinitions::Ingest < Definition

  def initialize()
    super("ingest", "IngestToRawLambda", [Properties::Kinesis])
  end
end
