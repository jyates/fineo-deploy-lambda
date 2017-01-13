
module MetaDefinitions
  class TenantInfo < Definition

    def initialize()
      super("meta-tenant", "TenantCRUD", MetaDefinitions::UserProperties)
    end
  end
end
