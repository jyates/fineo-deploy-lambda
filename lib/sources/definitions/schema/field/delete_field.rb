
module SchemaDefinitions
  class DeleteField < Definition

    def initialize()
      super("field-delete", SchemaDefinitions::Properties)
      @function_def =
        Lambda::Func.new("DeleteField")
          .withDesc("Delete a field")
          .withMethodHandler("io.fineo.lambda.handle.schema.field.delete.DeleteField::handle")
          .withRole("Lambda-Schema-Mgmt")
    end
  end
end
