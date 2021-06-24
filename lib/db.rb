# frozen_string_literal: true

load './lib/db/schema.rb'

ActiveRecord::Base.logger = QBot.log

require_relative 'db/models/bot_record'

glob = File.join(__dir__, 'db', 'models', '*.rb')
Dir[glob].each { load _1 }
