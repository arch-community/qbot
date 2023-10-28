# frozen_string_literal: true

require_relative 'db/schema'

ActiveRecord::Base.logger = QBot.log

module QBot
  # Database interface
  module Database
    def self.init_db
      db_cfg = QBot.config.database

      ActiveRecord::Base.establish_connection ar_config(db_cfg)

      QBot.log.info 'Database connection initialized.'
    end

    def self.load_seed
      define_schema
    end
  end
end

def load_by_glob(*path_components)
  glob = File.join(__dir__, *path_components)

  Dir[glob].each { load _1 }
end

load_by_glob('db', 'concerns', '*.rb')
load_by_glob('db', 'models', '*.rb')
