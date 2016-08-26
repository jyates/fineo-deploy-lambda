
class SourceLoader
  def initialize(type, arr, clazz)
    Definitions[type] = arr
    @arr = arr
    @moduleName = clazz.name
  end

  def load(path)
    Dir["#{__dir__}/#{path}/*.rb"].each { |f|
      require f
      source = File.basename(f, ".rb")
      clazz = source.split('_').collect!{ |w| w.capitalize }.join
      @arr << Object.const_get("#{@moduleName}::#{clazz}").new()
    }
  end
end
