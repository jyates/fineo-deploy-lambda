
require_relative 'arg_opt'

module Properties

  class Property
    attr_reader :opts

    def initialize()
      @opts = []
    end

    def addProps(manager)
      manager.addAll(@opts)
    end
  end
end

# Simple helper that just includes all the different source modules
Dir["#{__dir__}/properties/*.rb"].each { |f|
  require f
}
