
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source_loader'

module MetaDefinitions

  UserProperties = [Properties::Dynamo.new().withUserInfoMgmt()]
  TenantProperties = [
    # Access to the user/tenant info table
    Properties::Dynamo.new().withUserInfoMgmt(),
    Properties::InternalApi.new().withCreateSchema()
  ]

  DeviceProperties = [
    # access to the device table
    Properties::Dynamo.new().withDeviceMgmt(),
    # group information for device users
    Properties::Iam.new().withDeviceKeyMgmt()
  ]

  DEFINITIONS = []

  loader = SourceLoader.new("Meta", DEFINITIONS, MetaDefinitions)
  loader.load("meta")
end
