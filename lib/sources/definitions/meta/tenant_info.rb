
module MetaDefinitions
  class TenantInfo < Definition

    def initialize()
      super("tenant-info", "TenantRUD", MetaDefinitions::TenantProperties)
    end
  end
end
