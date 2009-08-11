$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
ENV['RACK_ENV'] = 'cucumber'
require 'codenote'
FileUtils.rm_f(CodeNote.root_path_to('db','cucumber.sqlite3'))

require 'spec/expectations'
require 'rbconfig'
require 'culerity'

#Sinatra::Base.set :environment, :test
#Sinatra::Base.set :run, false
#Sinatra::Base.set :raise_errors, true



class CodeNoteWorld
  include Spec::Expectations
  include Spec::Matchers

  extend Forwardable
  def_delegators CodeNoteWorld, :working_dir, :codenote_bin, :codenote_load_bin, :culerity_server

  def self.culerity_server
    @culerity_server ||= Culerity::run_server
  end

  def self.close_server
    @culerity_server.close if @culerity_server
  end

  def self.working_dir
    @working_dir ||= File.expand_path(File.join(File.dirname(__FILE__), "/../../tmp"))
  end

  def self.bin(file)
    File.expand_path(File.join(File.dirname(__FILE__), "/../../bin/#{file}"))
  end

  def self.codenote_bin
    @codenote_bin ||= bin('codenote')
  end

  def self.codenote_load_bin
    @codenote_load_bin ||= bin('codenote_load')
  end

  def initialize
    @host = "http://localhost:5678"
  end

  def browser
    @browser ||= Culerity::RemoteBrowserProxy.new culerity_server, {:browser => :firefox}
  end

  def close_browser
    @browser.exit if @browser
  end

  def path(relative_path)
    @host + relative_path
  end


  def codenote_load(args)
    ruby("#{codenote_load_bin} #{args}")
  end

  def codenote(args)
    ruby("#{codenote_bin} --no-launch #{args}")
    sleep 2
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

    #def background_jobs
    #  @background_jobs ||= []
    #end

    #def run_in_background(command)
      #in_working_dir do
      #pid = fork
        #if pid
          #background_jobs << pid
        #else
          #STDOUT.replace(output = File.open("#{working_dir}/server.log", "w"))
          #STDERR.replace(output)
          #ENV['RACK_ENV'] = 'test'
          #exec command
          #exit 0
        #end
      #end
      #sleep 2.0
    #end

    #def terminate_background_jobs
      #if @background_jobs
        #@background_jobs.each do |pid|
          #Process.kill(Signal.list['TERM'], pid)
        #end
      #end
    #end

  ## it seems like this, and the last_* methods, could be moved into RubyForker-- is that being used anywhere but the features?
  def ruby(command)
    stderr_file = Tempfile.new('codenote')
    stderr_file.close
    Dir.chdir(working_dir) do
      @stdout = fork_ruby(command, stderr_file.path)
    end
    @stderr = IO.read(stderr_file.path)
    @exit_code = $?.to_i
  end

  ## Forks a ruby interpreter with same type as ourself.
  ## jruby will fork jruby, ruby will fork ruby etc.
  def fork_ruby(args, stderr=nil)
    config       = ::Config::CONFIG
    interpreter  = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
    cmd = "RACK_ENV=cucumber #{interpreter} #{args}"
    cmd << " 2> #{stderr}" unless stderr.nil?
    `#{cmd}`
  end

end

World do
  CodeNoteWorld.new
end

Before do
  FileUtils.rm_rf   CodeNoteWorld.working_dir
  FileUtils.mkdir_p CodeNoteWorld.working_dir
end


After do
  `#{codenote_bin} --kill`
  close_browser
  #terminate_background_jobs
end

at_exit do
  CodeNoteWorld.close_server
end

