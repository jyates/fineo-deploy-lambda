
require 'source/util/target'
require 'build/properties'

class Schema

  VERSION = "2.0-SNAPSHOT"

  attr_reader :targets

  def initialize(info)
    @dir = info["dir"]
    @targets = []
    info["targets"].each{|target|
      case target
      when "org"
        @targets << field?("org")
      when Hash
        arr = target.shift
        case arr[0]
        when 'metric'
          arr[1].each{|mt|
            case mt
            when "delete", "update", "field"
              @targets << field?("metric-#{mt}")
            else
              raise "Unexpected metric function: #{mt}"
            end
          }
        when 'field'
          arr[1].each{|ft|
            case ft
              when "delete", "update"
                @targets << field?("field-#{ft}")
              else
                raise "Unexpected field function: #{ft}"
            end
          }
        end
      else
        raise "Unexpected schema target: #{target}"
      end
    }
  end

private

  def field?(name)
    delete = Target.new(name, @dir, "schema-lambda-#{VERSION}-aws.jar")
    Properties::Dynamo.new().withSchemaStore().withCreateTable().addProps(delete)
    delete
  end
end
