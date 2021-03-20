# frozen_string_literal: true

# Configurable snippets
module Snippets
  extend Discordrb::Commands::CommandContainer

  command :listsnippets, {
    aliases: [:ls],
    help_available: true,
    usage: '.ls',
    min_args: 0,
    max_args: 0
  } do |event|
    snippets = Snippet.where(server_id: event.server.id)

    if !snippets || snippets.empty?
      embed event, t('snippets.list.none-found')
    else
      event.channel.send_embed do |m|
        m.title = t('snippets.list.title')
        m.description = snippets.map(&:name).join(', ')
      end
    end
  end

  command :snippet, {
    aliases: [:s],
    help_available: true,
    usage: '.s <snippet name>',
    min_args: 1,
    max_args: 1
  } do |event, name|
    snippet = Snippet.find_by(server_id: event.server.id, name: name)

    if snippet
      if snippet.embed
        embed event, snippet.text
      else
        event.respond snippet.text
      end
    else
      embed event, t('snippets.snippet.not-found')
    end
  end
end
