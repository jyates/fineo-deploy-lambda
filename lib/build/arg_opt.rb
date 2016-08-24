
class ArgOpts
  attr_reader :value_extract
  attr_accessor :key, :value

  def initialize(key, value, value_extractor)
    @key = key
    @value = value
    @value_extract = value_extractor
  end

  def ArgOpts.simple(key, value, desc)
    ArgOpts.new(key, value, ->(props) {
      ref = ArgOpts.get_reference(props, key)
      if ref.nil?
        puts "WARN: #{key} not found in properties: #{desc}"
        return value
      end
      puts "Using #{key} => #{ref}"
      ref
     })
  end

  def ArgOpts.ref(key, value, source, desc)
    ArgOpts.new(key, value, ->(props){
      reference = ArgOpts.get_reference(props, key, desc)
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
    properties = type.empty? ? props : props[type]["properties"]
    reference = properties
    parts.each{|key|
      reference = reference[key]
      return nil if reference.nil?
    }
    reference
  end
end
