require 'rubygems'
require 'sinatra/base'
require 'fileutils'
#require 'haml/util'
#require 'haml/engine'
require 'activerecord'

module CodeNote
  class << self
    def root
      @root ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
    end

    def reset_home
      @home = nil
      ENV['CODENOTE_HOME'] = nil
    end

    def home
      @home ||= ENV['CODENOTE_HOME'] || root
    end

    def home_path_to(*relative_path)
      File.join(home, *relative_path)
    end

    def root_path_to(*relative_path)
      File.join(root, *relative_path)
    end

    def database_settings
      home_db_file = home_path_to('config','database.yml')
      unless File.exist?(home_db_file)
        FileUtils.cp(root_path_to('config', 'database.example.yml'), home_db_file)
      end
      db_config = YAML.load(ERB.new(File.read(home_db_file)).result)
      (db_config[environment.to_s]).symbolize_keys
    end

    def environment
      Sinatra::Application.environment
    end

    def logger
      @logger ||= (
        if development?
          Logger.new(STDOUT)
        else
          FileUtils.mkdir_p(CodeNote.home_path_to('log'))
          log_path = CodeNote.home_path_to('log', "#{environment}.log")
          Logger.new(log_path)
        end
      )
    end

    def logger=(logger)
      @logger = logger
    end

    def development?; environment == :development end
    def production?;  environment == :production  end
    def test?;        environment == :test        end

  end

end

$LOAD_PATH.unshift(CodeNote.root_path_to('lib')) unless $LOAD_PATH.include?(CodeNote.root_path_to('lib'))


