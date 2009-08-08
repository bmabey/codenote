$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'codenote'

require 'spec/expectations'
require 'rbconfig'

module RubyForker
end
class CodeNoteWorld
  include Spec::Expectations
  include Spec::Matchers

  extend Forwardable
  def_delegators CodeNoteWorld, :working_dir, :codenote_bin

  def self.working_dir
    @working_dir ||= File.expand_path(File.join(File.dirname(__FILE__), "/../../tmp"))
  end

  def self.codenote_bin
    @codenote_bin ||= File.expand_path(File.join(File.dirname(__FILE__), "/../../bin/codenote"))
  end

  def codenote(args)
    run_in_background("#{codenote_bin} #{args}")
  end

  def create_file(file_name, contents)
    file_path = File.join(working_dir, file_name)
    File.open(file_path, "w") { |f| f << contents }
  end

  def last_stdout
    @stdout
  end

  def last_stderr
    @stderr
  end

  def last_exit_code
    @exit_code
  end

  def written(stream)
    case(stream)
      when 'stdout' then last_stdout
      when 'stderr' then last_stderr
      else raise "Unknown stream: #{stream}"
    end
  end

  # Okay, so private doesn't mean much in the context of a Cucumber world..
  # These methods are basically support methods for the public methods which I 
  # expect the steps to use.  (i.e. steps don't use the methods below)
  private
    def in_working_dir(&block)
      Dir.chdir(working_dir, &block)
    end

    def background_jobs
      @background_jobs ||= []
    end

    def run_in_background(command)
      pid = fork
      in_working_dir do
        if pid
          background_jobs << pid
        else
          # STDOUT.close
          # STDERR.close
          exec command
        end
      end
      sleep 0.2
    end

    def terminate_background_jobs
      if @background_jobs
        @background_jobs.each do |pid|
          Process.kill(Signal.list['TERM'], pid)
        end
      end
    end

  ## it seems like this, and the last_* methods, could be moved into RubyForker-- is that being used anywhere but the features?
  #def ruby(args)
    #stderr_file = Tempfile.new('codenote')
    #stderr_file.close
    #Dir.chdir(working_dir) do
      #@stdout = fork_ruby("-I #{rspec_lib} #{args}", stderr_file.path)
    #end
    #@stderr = IO.read(stderr_file.path)
    #@exit_code = $?.to_i
  #end

  ## Forks a ruby interpreter with same type as ourself.
  ## jruby will fork jruby, ruby will fork ruby etc.
  ## JRruby does not yet support Kernel.fork AFAIK so this actually shells out.
  #def fork_ruby(args, stderr=nil)
    #config       = ::Config::CONFIG
    #interpreter  = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
    #cmd = "#{interpreter} #{args}"
    #cmd << " 2> #{stderr}" unless stderr.nil?
    #`#{cmd}`
  #end

end

World do
  CodeNoteWorld.new
end

Before do
  FileUtils.rm_rf   CodeNoteWorld.working_dir
  FileUtils.mkdir_p CodeNoteWorld.working_dir
end

After do
  terminate_background_jobs
end

