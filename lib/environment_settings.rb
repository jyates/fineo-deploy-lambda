
module EnvironmentSettings

  def simplify(hash)
    hash.select{|k,v|
      !v.nil?
    }
  end

  def append(arr, env_name, name)
    value = ENV[env_name]
    inc = @options.all || value == "true"
    arr << name if inc
  end

  def as_input(input, name, dir_key)
    return nil if input.empty?
    dir = ENV[dir_key]
    raise "No source directory specified for #{name} => ENV[#{dir_key}]!" if dir.nil?
    info = {"dir" => dir, "targets" => input}
    {name => { "info" => info}}
  end
end