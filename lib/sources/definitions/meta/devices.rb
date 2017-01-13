
module MetaDefinitions
  class Devices < Definition

    def initialize()
      super("device-devices", "Device", MetaDefinitions::DeviceProperties)
    end
  end
end
