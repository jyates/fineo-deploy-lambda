
require 'build/arg_opt'

class Target

  attr_reader :name, :jar, :args, :jarname

  def initialize(name, dir, jarname)
    @name = name
    @jarname = jarname
    @jar = File.join(dir, jarname)
    @args = []
  end

  def option(property_name, default_value, description)
     args << ArgOpts.simple(property_name, default_value, description)
  end

  def test_prefixable_option(property_name, default_name, description)
    args << ArgOpts.prefix(property_name, default_value, description)
  end

  def addAll(options)
    @args += options
  end

  def properties?(prefix="fineo")
    props = {}
    @args.each{|opt|
      props["#{prefix}.#{opt.key}"] = opt.value
    }
    return props
  end
end
