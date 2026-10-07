# frozen_string_literal: true

QBot.log.warn 'The queries module is deprecated and its commands only ' \
              'print a notice; remove it from `modules` in the config'

# Queries (deprecated in favour of forum channels)
module Queries
  extend Discordrb::Commands::CommandContainer

  command :query, { aliases: [:q], help_available: false } do
    embed t('queries.deprecated')
  end

  command :openqueries, { aliases: [:oq], help_available: false } do
    embed t('queries.deprecated')
  end

  command :closequery, { aliases: [:cq], help_available: false } do
    embed t('queries.deprecated')
  end
end
