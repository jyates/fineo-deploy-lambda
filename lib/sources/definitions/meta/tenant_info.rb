
module MetaDefinitions
  class TenantInfo < Definition

    def initialize()
      super("tenant", "TenantCRUD", MetaDefinitions::UserProperties)
    end
  end
end
