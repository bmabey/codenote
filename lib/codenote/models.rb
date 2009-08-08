ActiveRecord::Base.establish_connection(CodeNote.database_settings)
ActiveRecord::Base.logger = CodeNote.logger
ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate(CodeNote.root_path_to('db', 'migrate'))

require CodeNote.root_path_to('vendor', 'acts_as_list')
ActiveRecord::Base.send(:include, ActiveRecord::Acts::List)

require 'codenote/models/presentation'
require 'codenote/models/slide'

