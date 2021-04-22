# frozen_string_literal: true

# Configurable snippets
module Quotes
  extend Discordrb::Commands::CommandContainer

  command :grab, {
    help_available: false, # TODO write help later
    usage: '.grab @user',
    min_args: 1,
    max_args: 1,
  } do |event, target|
    # TODO make this nicer. Feels like a hack.
    target_id = Integer(target[3..-2])
    event.channel.history(5, event.message.id).each { |m|
      if (m.author.id == target_id) and (not m.from_bot?)
        Quote.create(server_id: event.server.id,
                     user_id: m.author.id,
                     text: m.content)
        # TODO embed t(something.quotes.success) -- write docs later
        break
      end
    }
    nil
  end

  # REFER TO WIKI FOR FUNCIONALITY
  # https://wiki.archlinux.org/index.php/Phrik#Grab
  # TODO
  # next step is to write a command to get a quote from the database
  # before this happens, I must:
  # - create the table for this
  # - make .grab write to the DB
  # - write documentation for .grab
end
