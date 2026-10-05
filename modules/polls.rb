# frozen_string_literal: true

QBot.log.warn 'The polls module is deprecated and its commands only print ' \
              'a notice; remove it from `modules` in the config'

# Polls (deprecated in favour of Discord's native polls)
module Polls
  extend Discordrb::Commands::CommandContainer

  command :poll, { help_available: false } do
    embed t('polls.deprecated')
  end
end
