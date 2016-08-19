module Lambda

  PARENT_ACCOUNT_ID = "766732214526"
  class Func
    attr_reader :name, :desc, :handler, :role, :timeout, :memory

    def initialize(name)
      @name = name
      @timeout = 40 # seconds
      @memory = 256 # MB
    end

    def withMethodHandler(call)
      @handler = call
      self
    end

    def withRole(name)
      @role = "arn:aws:iam::#{PARENT_ACCOUNT_ID}:role/#{name}"
      self
    end

    def withDesc(description)
      @desc = description
      self
    end

    def withTimeout(timeoutSeconds)
      @timeout = timeoutSeconds
      self
    end

    def withMemory(memoryMB)
      @memory = memoryMB
      self
    end

    def to_aws_hash
      hash = {}
      hash[:function_name] = @name
      hash[:role] = @role
      hash[:description] = @desc
      hash[:handler] = @handler
      hash[:timeout] = @timeout
      hash[:memory_size] = @memory
      hash[:runtime] = "java8"
      hash
    end
  end
end
