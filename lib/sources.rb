
require 'sources/util/target'
require 'build/properties'
require 'sources/property_module'

SOURCES = {}
# Simple helper that just includes all the different source modules
Dir["#{__dir__}/sources/type/*.rb"].each { |f|
  require f

  # enable simple loading based on the name of the file we load
  source = File.basename(f, ".rb")
  clazz = source.split('_').collect!{ |w| w.capitalize }.join
  SOURCES[source] = lambda {|info|
    Object.const_get(clazz).new(info)
  }
}
