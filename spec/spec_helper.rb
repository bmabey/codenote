require 'spec'
ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'codenote'

require 'rubygems'
require 'fakefs/safe'
require 'database_cleaner'
require 'nokogiri'
require 'faketwitter'

FakeWeb.allow_net_connect = false

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }

Spec::Example::ExampleGroupFactory.register('codenote/runners', RunnerExampleGroup)

Spec::Runner.configure do |config|
  config.extend FakeFSHelpers
  config.include SpecHelpers

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, :except => %w[schema_migrations]) # Not really needed when using in-memory DB...
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
