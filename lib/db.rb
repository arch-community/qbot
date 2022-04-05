# frozen_string_literal: true

require 'logger'

require_relative 'db/schema'
require_relative 'db/models/bot_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)

glob = File.join(__dir__, 'db', 'models', '*.rb')
Dir[glob].each { load _1 }
