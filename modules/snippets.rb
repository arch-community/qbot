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

    snippets = Snippet.where(server_id: event.server.id)

    if !snippets || snippets.size == 0
      embed event, 'No available snippets.'
    else
      event.channel.send_embed do |m|
        m.title = 'Available snippets'
        m.description = snippets.map(&:name).join(', ')
      end
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

    snippet = Snippet.find_by(server_id: event.server.id, name: name)

    if snippet
      if snippet.embed
        embed event, snippet.text
      else
        event.respond snippet.text
      end
    else
      embed event, 'Snippet not found!'
    end
  end
end
