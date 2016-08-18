
module Source
  def self.load(arr, path)
    Dir["#{__dir__}/#{path}/*.rb"].each { |f|
      require f
      source = File.basename(f, ".rb")
      clazz = source.split('_').collect!{ |w| w.capitalize }.join
      arr << Object.const_get("SchemaDefinitions::#{clazz}").new()
    }
  end
end
