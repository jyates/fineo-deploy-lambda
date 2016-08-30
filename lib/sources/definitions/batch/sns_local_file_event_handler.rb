
class BatchDefinitions::SnsLocalFileEventHandler < BatchDefinition

  def initialize()
    super("sns-local",  "BatchSnsS3LocalFileEventHandler",
      BatchDefinitions::Manifest_Properties,
      ["lambda-prepare", "sns-handler"])
  end
end
