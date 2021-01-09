# frozen_string_literal: true

# Blacklist commands
module Blacklist
  extend Discordrb::Commands::CommandContainer

  command :blacklist, {
    aliases: [:bl],
    help_available: true,
    usage: '.bl [channel]',
    min_args: 0,
    max_args: 1
  } do |event, ch|
    channel_id = ch ? ch.to_i : event.channel.id

    bl = BlacklistEntry.where(channel_id: channel_id)

    event.channel.send_embed do |m|
      m.title = t('blacklist.bl.title')
      m.description = bl.map(&:regex).map { "`#{_1}`" }.join("\n")
    end
  end
end

QBot.bot.message do |event|
  sc = ServerConfig[event.server.id]
  if (event.author.id == QBot.bot.profile.id) ||
     (sc.modules_conf['disabled'].include? 'blacklist')
    break
  end

  contents = event.message.text

  bl = BlacklistEntry.where(channel_id: event.channel.id)
  bl.map(&:re)
    .filter { |re| re.match? event.message.text }
    .each do |r|
      event.message.author.pm t('blacklist.message', r, contents)
      event.message.delete
      break
    end
end
