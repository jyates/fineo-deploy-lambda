
require 'build/arg_manager'
require 'rubygems'
require 'util/zipdir'

module SourceHandler

  def build_properties(source, testing, args)
    # add the options from each source
    jars = source.targets
    manager = ArgManager.new
    jars.each{|jar|
      manager.addAll(jar.args)
    }

    # parse the options into the manager, which sets the options
    parser = OptionParser.new do |opts|
      manager.getOpts(opts)
    end
    parser.parse(args)

    manager.build(testing)
  end

  def print_target_properties(source, common_props, verbose=nil)
    return if verbose.nil?

    jars = source.targets
    puts "Source: #{source.class}"
    jars.each{|jar|
      puts "\t#{jar.name}"
      puts "\t   Properties:"
      jar.properties?.each{|k,v|
        puts "\t\t#{k} => #{v}"
      }
      common_props.each{|k,v|
        puts "\t\t#{k} => #{v}"
      }
    }
  end

  def update_jars(tmp, out, source, common_properties, verbose=nil)
    jars = []
    source.targets.each{|target|
      # unzip the jar into a temp directory
      unpack = File.join(tmp, source.class.name, target.name)
      FileUtils.mkdir_p unpack
      `cd #{unpack}; jar -xf #{target.jar}`

      # write the properties into the property file
      hash = target.properties?
      hash.merge!(common_properties)
      props = File.join(unpack, $PROP_FILE)
      File.open(props, 'w'){|file|
        hash.each{|k,v|
          file.puts("#{k}=#{v}")
        }
      }

      unless verbose.nil?
        puts "Properties: #{target.jar}"
        File.open(props, "r") do |f|
          f.each_line do |line|
            puts "\t#{line}"
          end
        end
      end

      # figure out where we are actually writing
      outdir = File.join(out, source.class.name, target.name)
      FileUtils.mkdir_p outdir
      outjar = File.join(outdir, target.jarname)

      # rezip the jar
      ZipFileGenerator.new(unpack, outjar).write
      puts "  Updated: #{outjar}" unless verbose.nil?
      jars << outjar
    }
    jars
  end

  def create_tmp(dir)
    if Dir.exists? dir
      out = "#{dir}.old.#{Time.now.to_i}"
      FileUtils.mv(dir,out)
    end
    FileUtils.mkdir_p dir
  end
end
