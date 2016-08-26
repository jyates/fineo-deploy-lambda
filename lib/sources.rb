
# common requires across definitions
require 'sources/definitions/definition'
require 'function/lambda'
require 'sources/definitions/source_loader'

require 'sources/util/target'
require 'build/properties'
require 'sources/type/source_type'

SOURCES = {}
Definitions = {}
# Simple helper that just includes all the different source modules
Dir["#{__dir__}/sources/type/*.rb"].each { |f|
  require f

  # enable simple loading based on the name of the file we load
  source = File.basename(f, ".rb")
  next if source == "source_type" # base class
  clazz = source.split('_').collect!{ |w| w.capitalize }.join
  source.gsub!("_", "-") # update name to something more commonly written
  SOURCES[source] = lambda {|info|
    Object.const_get(clazz).new(info)
  }
}

