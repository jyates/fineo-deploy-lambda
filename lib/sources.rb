
SOURCES = {}
# Simple helper that just includes all the different source modules
Dir["#{__dir__}/source/*.rb"].each { |f|
  require f

  # enable simple loading based on the name of the file we load
  source = File.basename(f, ".rb")
  clazz = source.capitalize
  SOURCES[source] = lambda {|info|
    Object.const_get(clazz).new(info)
  }
}
