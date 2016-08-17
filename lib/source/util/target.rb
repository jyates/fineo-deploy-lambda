
require 'build/arg_opt'

class Target

  attr_reader :name, :jar, :args

  def initialize(name, jar)
    @name = name
    @jar = jar
    @args = []
  end

  def option(property_name, default_value, description)
     args << ArgOpts.simple(property_name, default_value, description)
  end

  def test_prefixable_option(property_name, default_name, description)
    args << ArgOpts.prefix(property_name, default_value, description)
  end

  def properties?(prefix)
    props = {}
    opts.each{|opt|
      props["#{prefix}.#{opt.key}"] = opt.value
    }
    return props
  end
end
