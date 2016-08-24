
module StreamDefinitions
  class Storage < Definition

    def initialize()
      super("storage", "AvroToStorage", StreamDefinitions::Properties)
    end
  end
end
