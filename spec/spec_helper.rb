require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'codenote'

require 'rubygems'
require 'fakefs/safe'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Example::ExampleGroupFactory.register('codenote/runners', RunnerExampleGroup)
Spec::Runner.configure do |config|
  config.extend FakeFSHelpers
  config.include SpecHelpers
end
