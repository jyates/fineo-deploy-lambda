
module SchemaDefinitions
  class Org < Definition

    def initialize()
      super("org", "SchemaInternalCreateOrg", SchemaDefinitions::Properties)
    end
  end
end
