# frozen_string_literal: true

# Globally accessible properties of the bot
module QBot
  class << self
    attr_accessor :bot, :log, :config, :options, :version
  end
end
