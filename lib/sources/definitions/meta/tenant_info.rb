
module MetaDefinitions
  class TenantInfo < Definition

    def initialize()
      super("meta-tenant", "TenantCRUD", MetaDefinitions::TenantProperties)
    end
  end
end
