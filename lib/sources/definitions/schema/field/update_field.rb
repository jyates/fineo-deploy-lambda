
module SchemaDefinitions
  class UpdateField < Definition

    def initialize()
      super("field-update", SchemaDefinitions::Properties)
      @function_def =
        Lambda::Func.new("UpdateField")
          .withDesc("Update a field")
          .withMethodHandler("io.fineo.lambda.handle.schema.field.update.UpdateField::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
