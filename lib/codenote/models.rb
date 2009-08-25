ActiveRecord::Base.establish_connection(CodeNote.database_settings)
ActiveRecord::Base.logger = CodeNote.logger
ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate(CodeNote.root_path_to('db', 'migrate'))

require CodeNote.root_path_to('vendor', 'acts_as_list')
require CodeNote.root_path_to('vendor', 'acts_as_state_machine', 'lib', 'acts_as_state_machine')

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::List
  include ScottBarron::Acts::StateMachine
end

require 'codenote/models/presentation'
require 'codenote/models/slide'

