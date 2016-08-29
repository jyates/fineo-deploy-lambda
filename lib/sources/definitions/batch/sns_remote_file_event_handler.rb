
class BatchDefinitions::SnsRemoteFileEventHandler < BatchDefinition


  def initialize()
    super("sns-remote",  "SnsS3RemoteFileEventHandler",
      BatchDefinitions::Manifest_Properties,
      ["lambda-prepare", "sns-handler"])
  end
end
