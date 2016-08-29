
class BatchDefinitions::LaunchEmrCluster < BatchDefinition

  def initialize()
    super("launchemr",  "LaunchEMRCluster",
    [Properties::Dynamo.new().withCreateBatchManifestTable(),
      Properties::LaunchEmr],
      ["lambda-emr-launch"])
  end
end
