
module MetaDefinitions
  class DeviceKeys < Definition

    def initialize()
      super("device-keys", "DeviceKeys", MetaDefinitions::DeviceProperties)
    end
  end
end
