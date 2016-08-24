
module StreamDefinitions
  class Raw < Definition

    def initialize()
      super("raw", "RawToAvro", StreamDefinitions::Properties)
    end
  end
end
