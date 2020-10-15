# frozen_string_literal: true

require 'xkcd'

# XKCD comic fetching
module Xkcd
  extend Discordrb::Commands::CommandContainer

  command :xkcd, {
    help_available: true,
    description: 'Fetches an XKCD comic by number',
    usage: '.xkcd <number>',
    min_args: 1
  } do |event, *args|
    log(event)

    num = args[0].to_i

    event.respond Xkcd[num]
  end
end

