def all_snippets(server)
  $config.global.snippets + $config&.servers[server.id]&.snippets
end

module Snippets
  extend Discordrb::Commands::CommandContainer

  command :listsnippets, {
    aliases: [ :ls ],
    help_available: true,
    description: 'Lists available snippets',
    usage: '.ls',
    min_args: 0,
    max_args: 0
  } do |event|
    log(event)

    event.channel.send_embed do |m|
      m.title = 'Available snippets'
      m.description = all_snippets(event.server).map { _1.name }.join(', ')
    end
  end

  command :snippet, {
    aliases: [ :s ],
    help_available: true,
    description: 'Posts a snippet',
    usage: '.s <snippet name>',
    min_args: 1,
    max_args: 1
  } do |event, name|
    log(event)

    text = all_snippets(event.server).find { _1.name == name }.text
    event.channel.send_embed { _1.description = text || 'Snippet not found' }
  end
end
