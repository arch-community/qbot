# frozen_string_literal: true

def formatted_name(user) = "#{user.name}##{user.discriminator}"

def find_prefix(message)
  if message.channel.pm?
    QBot.config.default_prefix || '.'
  else
    ServerConfig[message.server.id].server_prefix
  end
end

def prefixed(text) = "#{QBot.bot.current_prefix}#{text}"

def cmd_prefix(message)
  pfx = find_prefix(message)

  if message.text.start_with?("#{pfx} ")
    message.text[(pfx.length + 1)..]
  elsif message.text.start_with?(pfx)
    message.text[pfx.length..]
  end
end

def strip_command(text, command) = text.sub(/^#{prefixed command} /, '').chomp

def log_embed(event, channel, user, extra)
  embed(target: channel) do |m|
    m.author = { name: formatted_name(user), icon_url: user.avatar_url }
    m.title = 'Command execution'
    m.fields = [
      { name: 'Command', value: event.message.to_s.truncate(1024), inline: true },
      { name: 'User ID', value: user.id, inline: true }
    ]
    extra && m.fields << [{ name: 'Information', value: extra }]
    m.timestamp = Time.now
  end
end

def log(event, extra = nil)
  user = event.author

  chan_id = event.channel.pm? ? nil : ServerConfig[event.server.id].log_channel_id

  QBot.log.info("command execution by #{formatted_name(user)}: " \
                "#{event.message}#{extra && "; #{extra}"}")

  if chan_id
    begin
      lc = QBot.bot.channel(chan_id)
    rescue Discordrb::Errors::UnknownChannel
      lc = nil
      event.server.owner.pm(t('log-channel-gone'))
    end
  else
    lc = nil
  end
  log_embed(event, lc, user, extra) if lc
end

# Listen for a user response
def user_response(event)
  response = event.bot.add_await!(Discordrb::Events::MentionEvent, in: event.channel, from: event.author)
  response.message.text.split[1].to_i
end

def unescape(str) = "\"#{str}\"".undump

def cmd_target(event, arg)
  if (id = arg.to_i) != 0
    event.bot.user(id)
  else
    event.message.mentions[0] || event.author
  end
end

def to_word(num)
  numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  words = %w[zero one two three four five six seven eight nine ten]
  map = numbers.zip(words).to_h
  map[num] || num
end

def to_emoji(num) =
  [num.to_s.ord, 65_039, 8_419].map { _1.chr(Encoding::UTF_8) }.join
