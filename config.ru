require File.expand_path(File.dirname(__FILE__) + '/lib/codenote')
require 'codenote/application'

class CodeNotePresentation < CodeNote::Application
  set :public,      File.expand_path(File.dirname(__FILE__), "public")
  set :environment, :production
end

run CodeNotePresentation

