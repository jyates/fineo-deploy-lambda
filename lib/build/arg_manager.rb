
class ArgManager

  def initialize
    @opts = []
  end

  def add(*opt)
    @opts+= opt
  end

  def addAll(opt)
     @opts += opt
  end

  # Bind the specified properties to the collected arguments.
  def bind(props)
    @opts.each{|opt|
      value = opt.value_extract.call(props)
      opt.value = value
    }
  end
end
