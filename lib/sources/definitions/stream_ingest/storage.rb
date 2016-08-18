
module StreamDefinitions
  class Storage < Definition

    def initialize()
      super("storage", StreamDefinitions::Properties)
      function("AvroToStorage")
          .withDesc("Stores the avro-formated bytes into Dynamo and S3")
          .withMethodHandler("io.fineo.lambda.handle.staged.AvroToStorageWrapper::handle")
          .withRole("Lambda-Dynamo-Ingest-Role")
    end
  end
end
