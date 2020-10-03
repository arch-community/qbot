def formatted_name(u)
  "#{u.name}##{u.discriminator}"
end

def cmd_prefix(m)
  pfx = ServerConfig[m.channel.server.id].prefix
  m.text.start_with?(pfx) ? m.text[pfx.length..-1] : nil
end

def log(event, extra = nil)
  user = event.author
  username = formatted_name(event.author)

  chan_id = ServerConfig[event.server.id].log_channel_id

  QBot.log.info("command execution by #{username}: #{event.message}#{extra && "; #{extra}"}")

  if chan_id
    event.bot.channel(chan_id).send_embed do |m|
      m.author = { name: username, icon_url: user.avatar_url }
      m.title = 'Command execution'
      m.fields = [
        { name: 'Command', value: event.message.to_s },
        { name: 'User ID', value: user.id, inline: true },
        extra ? { name: 'Information', value: extra } : nil
      ].compact
      m.timestamp = Time.now
    end
  end
end

# Listen for a user response
def user_response(bot, event)
  event = bot.add_await!(Discordrb::Events::MentionEvent, in: event.channel, from: event.author)
  event.message.text.split[1].to_i
end

def embed(event, text)
  event.channel.send_embed { _1.description = text }
end
