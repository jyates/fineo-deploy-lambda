
class ArgOpts
  attr_reader :value_extract
  attr_accessor :key, :value

  def initialize(key, value, value_extractor)
    @key = key
    @value = value
    @value_extract = value_extractor
  end

  # Alias for property_ref
  def ArgOpts.simple(key, value, desc)
    ArgOpts.property_ref(key, value, desc)
  end

  # Looks up the key, split on '.' for a given type
  def ArgOpts.property_ref(key, value, desc)
    ArgOpts.new(key, value, ->(props) {
      ref = ArgOpts.get_reference(props, key)
      if ref.nil?
        puts "WARN: #{key} not found in properties: #{desc}"
        return value
      end
      ref
     })
  end

  # Lookup the [source] (split on '.') in the properties of the source.
  # For example, source = 'some.key' finds:
  # ...
  #  "source": {
  #   "properties": {
  #     "key": "value"    <---------- this value
  #   }}
  def ArgOpts.source(key, value, source, desc, fail_on_missing=false)
    ArgOpts.new(key, value, ->(props) {
      ref = ArgOpts.get_reference(props, source)
      if ref.nil?
        msg = "Missing property: #{source} to fill #{key} (#{desc})"
        if fail_on_missing
          raise msg
        end

        puts "WARN: #{msg}"
        return value
      end
      ref
     })
  end

  # Looks up the key (split on '.') in the properties
  def ArgOpts.direct(key, value, desc)
    ArgOpts.new(key, value, ->(props){
      parts = key.split "."
      ArgOpts.depth_search(parts, props)
    })
  end

  # Similar to the simple lookup, first gets a value for the reference in the properties
  # and then finds the matching reference under another subset of the properties.
  #
  # This is an odd one and really should only be used for legacy purposes....
  #
  # 1. [type] informs which information to lookup. If no type is specified, just uses the standard
  # properties, but otherwise looks for [type].properties
  # 2. After getting the properties, does a search for the remainder of the key (without the type)
  # and returns the properties present there at that depth (or just the root properties, if no
  # type specified)
  # 3.  Gets the parent properties to the found reference
  # 4. Looks up the [source] in the parent and the loads the value at the found reference
  #
  # Parameters:
  #  * key - of the form [type].[dot separated path]
  #  * value - output value for null
  #  * source - key to lookup in the parent of the reference (e.g. [type]'s full tree).
  def ArgOpts.ref(key, value, source, desc)
    ArgOpts.new(key, value, ->(props){
      reference = ArgOpts.get_reference(props, key)
      if reference.nil?
        puts "WARN: #{key} not found in properties: #{desc}"
        return value
      end

      type = key.split(".").shift
      parent = props[type]
      components = parent[source]
      components.each{|name, hash|
        return name if hash["refname"] == reference
      }
      raise "No property with reference #{reference} found!"
    })
  end

private

  def ArgOpts.get_reference(props, key)
    parts = key.split "."
    type = parts.shift
    if type.empty?
      properties = props
    else
      p = props[type]
      return nil if p.nil?
      properties = p["properties"]
    end
    ArgOpts.depth_search(parts, properties)
  end

  def ArgOpts.depth_search(parts, properties)
    parts.each{|key|
      properties = properties[key]
      return nil if properties.nil?
    }
    properties
  end
end
