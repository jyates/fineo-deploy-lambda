
class BatchDefinitions::SnsLocalFileEventHandler < BatchDefinition

  def initialize()
    super("sns-local",  "SnsS3LocalFileEventHandler",
      BatchDefinitions::Manifest_Properties,
      ["lambda-prepare", "sns-handler"])
  end
end
