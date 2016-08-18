
module SchemaDefinitions
  class Org < Definition

    def initialize()
      super("org", SchemaDefinitions::Properties)
      function("CreateOrg") \
          .withDesc("Create a basic org schema") \
          .withMethodHandler("io.fineo.lambda.handle.schema.create.CreateOrg::handle") \
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
