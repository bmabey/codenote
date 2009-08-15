require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CodeNote do
  before(:each) do
    CodeNote.reset_home
    Sinatra::Application.stub!(:environment).and_return(:development)
    CodeNote.logger = nil
  end

  after(:each) do
    CodeNote.reset_home
  end

  describe '::root' do
    it "returns the expanded path of where the CodeNote project/gem lives" do
      CodeNote.root.should == File.expand_path(File.join(File.dirname(__FILE__), '..'))
    end
  end

  describe '::home' do
    it "returns the path defined in the env var CODENOTE_HOME" do
      ENV['CODENOTE_HOME'] = '/tmp'
      CodeNote.home.should == '/tmp'
    end

    it "defaults to the root path" do
      CodeNote.home.should == CodeNote.root
    end

  end

  describe '::root_path_to' do
    it "joins the given relative path to the root path" do
      CodeNote.root_path_to('lib').should == File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
    end
  end

  describe '::home_path_to' do
    it "joins the given relative path to the home path" do
      ENV['CODENOTE_HOME'] = '/tmp'
      CodeNote.home_path_to('some','dir').should == "/tmp/some/dir"
    end
  end

  describe '::environment' do
    it "delegates to Sinatra::Application" do
      Sinatra::Application.should_receive(:environment).and_return(:foo)
      CodeNote.environment.should == :foo
    end
  end

  describe '::database_settings' do

    use_fakefs

    it "returns the database config for the given environment with the keys symbolized" do
      File.open(CodeNote.home_path_to('config', 'database.yml'), 'w') do |config|
        config << {'production' => {'foo' => 'bar'}, 'development' => {'baz' => 'foo'}}.to_yaml
      end
      CodeNote.database_settings.should == {:baz => 'foo'}
    end

    it "evaluates the config within ERB so that it can have access to constants" do
      ENV['CODENOTE_HOME'] = '/tmp'
      File.open(CodeNote.home_path_to('config', 'database.yml'), 'w') do |config|
        config << {'development' => {'database' => "<%= CodeNote.home_path_to('db.sqlite3') %>"}}.to_yaml
      end
      CodeNote.database_settings[:database].should == "/tmp/db.sqlite3"
    end

    context "when no database.yml exists" do
      it "copies the example database.yml for the root path to the home path" do
        example_file = {'development' => {'foo' => 'bar'}}.to_yaml
        File.open(CodeNote.root_path_to('config', 'database.example.yml'), 'w') do |config|
          config << example_file
        end
        ENV['CODENOTE_HOME'] = '/tmp'
        CodeNote.database_settings[:foo].should == 'bar'
        File.read("/tmp/config/database.yml").should == example_file
      end

    end
  end

  describe '::logger' do

    before(:each) do
      Sinatra::Application.stub!(:environment).and_return(:test)
      Logger.stub!(:new).and_return(@logger = mock('logger')) 
    end

    use_fakefs

    it "uses STDOUT when in development mode" do
      Sinatra::Application.stub!(:environment).and_return(:development)
      Logger.should_receive(:new).with(STDOUT)
      CodeNote.logger
    end

    it "places the logs based on the environment name in the home log path when not in development" do
      ENV['CODENOTE_HOME'] = '/tmp'
      Logger.should_receive(:new).with("/tmp/log/test.log")
      CodeNote.logger
    end

    it "creates the log path in the home dir when it doesn't exist" do
      ENV['CODENOTE_HOME'] = '/tmp'
      FileUtils.rm_rf('/tmp/log')
      CodeNote.logger
      File.exists?('/tmp/log').should be_true
    end

    it "returns the logger" do
     CodeNote.logger.should == @logger
    end

  end




end
