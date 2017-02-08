
module MetaDefinitions
  class TenantCreate < Definition

    def initialize()
      super("tenant-create", "TenantCreate", MetaDefinitions::TenantProperties)
    end
  end
end
