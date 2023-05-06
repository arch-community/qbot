# frozen_string_literal: true

require_relative 'db/schema'

ActiveRecord::Base.logger = QBot.log

# Database interface
module Database
  def self.dbname
    conf = QBot.config.database

    if QBot.options.state_dir && conf.type == 'sqlite3'
      File.join(QBot.options.state_dir, conf.db)
    else
      conf.db
    end
  end

  def self.init_db
    conf = QBot.config.database

    ActiveRecord::Base.establish_connection(
      adapter: conf.type,
      database: dbname,
      username: conf.user,
      password: conf.pass
    )
    QBot.log.info 'Database connection initialized.'
  end
end

def load_by_glob(*path_components)
  glob = File.join(__dir__, *path_components)

  Dir[glob].each { load _1 }
end

load_by_glob('db', 'concerns', '*.rb')
load_by_glob('db', 'models', '*.rb')
