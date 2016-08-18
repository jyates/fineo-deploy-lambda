
class Definition

  attr_reader :name, :properties, :func

  def initialize(name, properties)
    @name = name
    @path = name.split("-")
    @properties = properties
  end

  def matches?(stringOrHash)
    case stringOrHash
      when String
        return true if @path[0] == stringOrHash && @path.size == 1
      else
        return checkNext(deep_copy(@path), deep_copy(stringOrHash))
    end
    false
  end

  def function(name)
    @func = Lambda::Func.new(name)
  end

private

  def checkNext(path, hashOrString)
    # no more left for both path and hash/string
    pathEmpty = (path.nil? || path.empty?)
    hashEmpty = (hashOrString.nil? || hashOrString.empty?)
    return true if pathEmpty && hashEmpty # both are empty
    return false if pathEmpty ^ hashEmpty # only one is empty

    # just one value left in each, check that
    if hashOrString.size == 1 && path.size == 1
      return hashOrString[0] == path[0]
    end

    # must be some values in both
    arr = hashOrString.shift
    part = path.shift

    return part != arr[0] ? false : checkNext(path, arr[1])
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end
end
