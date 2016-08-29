
require 'build/arg_manager'
require 'rubygems'

module SourceHandler

  def build_properties(source, props, testing)
    # add the options from each source
    jars = source.targets
    manager = ArgManager.new
    jars.each{|jar|
      jar.args << ArgOpts.simple(".#{Building::TEST_KEY}", "", "Test prefix") unless testing.nil?
      manager.addAll(jar.args)
    }

    manager.bind(props)
  end

  def print_target_properties(source, verbose=nil)
    return if verbose.nil?

    jars = source.targets
    puts "Source: #{source.class}"
    jars.each{|jar|
      puts "\t#{jar.name}"
      puts "\t   Properties:"
      jar.properties?.each{|k,v|
        puts "\t\t#{k} => #{v}"
      }
    }
  end

  def update_jars(tmp, out, source, verbose=nil)
    jars = {}
    source.targets.each{|target|
      # unzip the jar into a temp directory
      unpack = File.join(tmp, source.class.name, target.name)
      FileUtils.mkdir_p unpack
      `cd #{unpack}; jar -xf #{target.jar}`

      # write the properties into the property file
      hash = target.properties?
      props = File.join(unpack, $PROP_FILE)
      File.open(props, 'w'){|file|
        hash.each{|k,v|
          file.puts("#{k}=#{v}")
        }
      }

      unless verbose.nil?
        puts "    Properties: #{target.jar}"
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
      outjar_tmp = File.basename(outjar)
      outdir = File.dirname(outjar)
      FileUtils.mkdir(outdir) unless File.exist? outdir
      cmd = "cd #{unpack}; jar cf #{outjar_tmp} *; cd -;mv #{unpack}/#{outjar_tmp} #{outjar}"
      `#{cmd}`
      puts "  Updated: #{outjar}" unless verbose.nil?
      jars[target.name] = outjar
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
