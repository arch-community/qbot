# frozen_string_literal: true

# Blacklist commands
module Blacklist
  extend Discordrb::Commands::CommandContainer

  command :blacklist, {
    aliases: [:bl],
    help_available: true,
    description: 'Lists blacklist entries for a channel',
    usage: '.bl [channel]',
    min_args: 0,
    max_args: 1
  } do |event, ch|
    channel_id = ch ? ch.to_i : event.channel.id

    bl = BlacklistEntry.where(channel_id: channel_id)
    
    event.channel.send_embed do |m|
      m.title = "Blacklist entries"
      m.description = bl.map(&:regex).map { "`#{_1}`" }.join(?\n)
    end
  end
end

QBot.bot.message do |event|
  sc = ServerConfig[event.server.id]
  return if event.author.id == QBot.bot.profile.id

  contents = event.message.text

  unless sc.modules_conf["disabled"].include? "blacklist"
    bl = BlacklistEntry.where(channel_id: event.channel.id)
    bl.map(&:re).each do |r|
      if r.match? event.message.text
        event.message.author.pm <<~END
          Your message contained text blocked by the following blacklist entry: `#{r}`.

          Original message:
          ```
          #{contents}
          ```
        END
        event.message.delete
        break
      end
    end
  end
end
