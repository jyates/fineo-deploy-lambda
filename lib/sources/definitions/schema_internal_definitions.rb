
module SchemaInternalDefinitions
  DEFINITIONS = []

  loader = SourceLoader.new("SchemaInternal", DEFINITIONS, SchemaInternalDefinitions)
  loader.load("schema-internal")
end
