
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

  def build(test_prefix)
    @opts.each{|opt|
      opt.value = opt.field_rename.call(test_prefix) unless test_prefix.nil?
    }
    # the values that live across all properties
    values = {}
    values["integration.test.prefix"] = test_prefix unless test_prefix.nil?
    values
  end

  def getOpts(parser)
     @opts.each{ |opt|
        key = opt.key.gsub(".", "-")
        parser.on("--#{key} <value>", "#{opt.desc}. DEFAULT: #{opt.value}") do |name|
          opt.value = name
        end
     }
  end
end
