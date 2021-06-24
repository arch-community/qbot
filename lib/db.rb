# frozen_string_literal: true

require_relative 'db/schema'
require_relative 'db/models/bot_record'

ActiveRecord::Base.logger = QBot.log

glob = File.join(__dir__, 'db', 'models', '*.rb')
Dir[glob].each { load _1 }
