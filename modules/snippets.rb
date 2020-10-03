# frozen_string_literal: true

# Configurable snippets
module Snippets
  extend Discordrb::Commands::CommandContainer

  command :listsnippets, {
    aliases: [:ls],
    help_available: true,
    description: 'Lists available snippets',
    usage: '.ls',
    min_args: 0,
    max_args: 0
  } do |event|
    log(event)

    event.channel.send_embed do |m|
      m.title = 'Available snippets'
      m.description = Snippet.where(server_id: event.server.id).map(&:name).join(', ')
    end
  end

  command :snippet, {
    aliases: [:s],
    help_available: true,
    description: 'Posts a snippet',
    usage: '.s <snippet name>',
    min_args: 1,
    max_args: 1
  } do |event, name|
    log(event)

    text = Snippet.where(server_id: event.server.id, name: name).text
    event.channel.send_embed { _1.description = text || 'Snippet not found' }
  end
end
