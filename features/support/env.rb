$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
ENV['RACK_ENV'] = 'cucumber'
FileUtils.rm_f(File.join(File.dirname(__FILE__), '..', '..', 'db','cucumber.sqlite3')) # so schema data is removed
require 'codenote'
require 'codenote/presentation_loader'
require 'codenote/models'

require File.dirname(__FILE__) + '/tcp_socket'

require 'spec/expectations'
#require 'celerity'
require 'culerity'
require 'faketwitter'
require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :truncation, {:except => %w[schema_migrations]}
DatabaseCleaner.clean




#Sinatra::Base.set :environment, :test
#Sinatra::Base.set :run, false
#Sinatra::Base.set :raise_errors, true



class CodeNoteWorld
  include Spec::Expectations
  include Spec::Matchers

  extend Forwardable
  def_delegators CodeNoteWorld, :working_dir, :codenote_bin, :codenote_load_bin, :culerity_server, :kill_codenote_server, :port

  def self.port
    5678
  end

  def self.culerity_server
    @culerity_server ||= Culerity::run_server
  end

  def self.close_culerity_server
    @culerity_server.exit_server if @culerity_server
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

  def self.start_codenote_server
    `#{codenote_bin} --no-launch`
  end

  def self.start_codenote_app_in_process
    require 'codenote/application'
    Thread.new do
      CodeNote::Application.set :logging, false
      CodeNote::Application.set :port, port
      logger = Logger.new(CodeNote.root_path_to('log', 'cucumber.log'))
      CodeNote::Application.use Rack::CommonLogger, logger
      puts 'Starting in-process server...'
      CodeNote::Application.run!
    end
    TCPSocket.wait_for_service_with_timeout :host => "localhost", :port => port, :timeout => 5
  end

  def self.kill_codenote_server
    `#{codenote_bin} --kill`
  end

  def self.codenote_load_bin
    @codenote_load_bin ||= bin('codenote_load')
  end

  def initialize
    @host = "http://localhost:#{port}"
    @browsers = []
  end

  def browser
    @browser ||= new_browser
  end

  def presenter_browser
    @presenter_browser ||= new_browser.tap { |b| login_presenter(b) }
  end

  def login_presenter(browser = browser)
    browser.goto path('/secret_login')
    browser.text_field(:label, 'Password').set('presentation_zen09')
    browser.button(:value, 'Login').click
  end

  def close_browsers
    culerity_server.close_browsers
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

  def new_browser
    Culerity::RemoteBrowserProxy.new(culerity_server, {:browser => :firefox}).tap { |b| @browsers << b }
  end

  def ruby(command, interpreter = 'current')
    run("#{RubyInterpreters[interpreter]} #{command}")
  end

  def run(command)
    Dir.chdir(working_dir) do
      stderr_file = Tempfile.new('codenote')
      stderr_file.close
      @stdout = `RACK_ENV=cucumber #{command} 2> #{stderr_file.path}`
      @stderr = File.read(stderr_file.path)
      @exit_code = $?.to_i
    end
  end

end


require 'rbconfig'
class RubyInterpreters
  def self.[](interpreter_name)
    interpreters[interpreter_name] or raise("Opps, no interpreter was defined for '#{interpreter_name}'. Please set one by setting a  #{interpreter_name.upcase}_BIN evn var.")
  end

  def self.interpreters
    @interpreters ||= {
      'current' => current_ruby,
      'jruby' => locate_jruby,
      'mri' => locate_mri
    }
  end

  def self.current_ruby
    @current_ruby ||= (
      config       = ::Config::CONFIG
      current = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
    )
  end

  def self.locate_jruby
    return ENV["JRUBY_BIN"] if ENV["JRUBY_BIN"]
    return current_ruby if RUBY_PLATFORM =~ /java/
  end

  def self.locate_mri
    return ENV["MRI_BIN"] if ENV["MRI_BIN"]
    return current_ruby unless RUBY_PLATFORM =~ /java/
    try_locations("/System/Library/Frameworks/Ruby.framework/1.8/Current/usr/bin/ruby")
  end

  def self.try_locations(*paths)
    paths.each do |path|
      return path if File.exist?(path)
    end
    nil
  end

  private_class_method :try_locations, :locate_jruby, :locate_mri, :current_ruby

end

World do
  CodeNoteWorld.new
end

Before do
  FileUtils.rm_rf   CodeNoteWorld.working_dir
  FileUtils.mkdir_p CodeNoteWorld.working_dir
end


After do
  FakeWeb.clean_registry
  close_browsers
end

# On load
CodeNoteWorld.start_codenote_app_in_process


at_exit do
  puts "Shutting down the Culerity server..."
  CodeNoteWorld.close_culerity_server
end


