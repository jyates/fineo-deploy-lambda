
class Definition

  attr_reader :name, :properties, :func_name, :config_key

  # * name - source environment name, where parent segments are separated by '-'
  # * func_name - name of the object definition (not the actual, eventual function name in AWS)
  # * properties - property definitions to add to the resulting jar
  def initialize(name, func_name, properties, config_key=nil)
    @name = name
    @path = name.split("-")
    @properties = properties.clone
    @func_name = func_name
    @config_key = config_key.nil? ? "lambda.#{@func_name}": config_key
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

private

  def checkNext(path, query)
    # no more left for both path and hash/string
    pathEmpty = (path.nil? || path.empty?)
    queryEmpty = (query.nil? || query.empty?)
    return true if pathEmpty && queryEmpty # both are empty
    return false if pathEmpty ^ queryEmpty # only one is empty

    if path.size == 1
      return false if query.is_a? Hash # has more values, but we are at the end
      # it should be an array
      return query.include? path[0]
    end

    # must be some values in both
    arr = query.shift
    part = path.shift

    return part != arr[0] ? false : checkNext(path, arr[1])
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end
end
