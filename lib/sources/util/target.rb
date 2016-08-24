
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

  def add(*options)
    if options.is_a? Array
      addAll(options)
    else
      addAll([options])
    end
  end

  def addAll(options)
    @args += options
  end

  def properties?(prefix="fineo")
    props = {}
    @args.each{|opt|
      key = "#{prefix}.#{opt.key}".gsub("..", ".")
      props[key] = opt.value
    }
    return props
  end
end
