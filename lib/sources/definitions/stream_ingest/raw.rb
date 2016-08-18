
module StreamDefinitions
  class Raw < Definition

    def initialize()
      super("raw", StreamDefinitions::Properties)
      @function_def =
        Lambda::Func.new("RawToAvro")
          .withDesc("Convert raw JSON records to avro encoded records")
          .withMethodHandler( "io.fineo.lambda.handle.raw.RawStageWrapper::handle")
          .withRole("Lambda-Raw-To-Avro-Ingest-Role")
    end
  end
end
