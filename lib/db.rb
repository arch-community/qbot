# frozen_string_literal: true

load './lib/db/schema.rb'

ActiveRecord::Base.logger = QBot.log

# Database interface
module Database
  def self.init_db
    conf = QBot.config.database
    ActiveRecord::Base.establish_connection(
      adapter: conf.type,
      database: conf.db,
      username: conf.user,
      password: conf.pass
    )
    QBot.log.info 'Database connection initialized.'
  end
end

glob = File.join(__dir__, 'db', 'models', '*.rb')

Dir[glob].each { |file| p file; load file }
