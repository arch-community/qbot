# frozen_string_literal: true

##
# Version declaration
module QBot
  class << self
    attr_accessor :version
  end
end

QBot.version = '8.0.0'
