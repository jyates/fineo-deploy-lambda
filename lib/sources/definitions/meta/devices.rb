
module MetaDefinitions
  class Devices < Definition

    def initialize()
      super("device-devices", "Devices", MetaDefinitions::DeviceProperties)
    end
  end
end
