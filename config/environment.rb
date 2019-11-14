require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'

#make sure to comment out the bottom line before seeding, weird bug
ActiveRecord::Base.logger.level = 1 # or Logger::INFO
