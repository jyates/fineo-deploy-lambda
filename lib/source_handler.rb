
require 'build/arg_manager'
require 'rubygems'
require 'zip'

module SourceHandler

  def build_properties(source, testing, args)
    jars = source.targets?
    manager = ArgManager.new
    jars.each{|jar|
      manager.addAll(jar.args)
    }
    parser = OptionParser.new do |opts|
      manager.getOpts(opts)
    end
    # at this point each of the jars should have the properties set
    parser.parse(args)
  end

  def print_target_properties(source, verbose=nil)
    return if verbose.nil?

    jars = source.targets?
    puts "Source: #{source.class}"
    jars.each{|jar|
      puts "\t #{jar.name}"
      puts "\t Properties:"
      jar.properties.each{|k,v|
        puts "\t\t#{k} => #{v}"
      }
    }
  end

  def update_jars(tmp, source, verbose=nil)
    source.targets?.each{|target|
      # unzip the jar into a temp directory
      `cd #{tmp}; jar -xf #{target.jar}`

      # write the properties into the property file
      hash = target.properties
      out = File.join(tmp, $PROP_FILE)
      File.open(out, 'w'){|file|
        hash.each{|k,v|
          file.write("#{k}=#{v}")
        }
      }

      unless verbose.nil?
        puts "Jar properties: #{target.jar}"
        File.open(out, "r") do |f|
          f.each_line do |line|
            puts "\t#{line}"
          end
        end
      end

      # rezip the jar
      File.rm(target.jar)
      entries = Dir.entries(tmp); entries.delete("."); entries.delete("..")
      io = Zip::File.open(target.jar, Zip::File::CREATE)
      writeEntries(entries, "", io)
      io.close();
    }
  end

private
    # A helper method to make the recursion work.
    private
    def writeEntries(entries, path, io)

      entries.each { |e|
        zipFilePath = path == "" ? e : File.join(path, e)
        diskFilePath = File.join(@inputDir, zipFilePath)
        puts "Deflating " + diskFilePath
        if  File.directory?(diskFilePath)
          io.mkdir(zipFilePath)
          subdir =Dir.entries(diskFilePath); subdir.delete("."); subdir.delete("..")
          writeEntries(subdir, zipFilePath, io)
        else
          io.get_output_stream(zipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
        end
      }
  end
end
