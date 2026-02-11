# frozen_string_literal: true

def embed(text = nil, target: nil)
  target ||= QBot.bot.embed_target
  reply_target = target.is_a?(Discordrb::Events::MessageEvent) ? target.message : nil

  target.send_embed('', nil, nil, false, false, reply_target) do |m|
    m.description = text if text
    yield m if block_given?
  end
end

def prefixed(text) = "#{QBot.bot.current_prefix}#{text}"

def log_embed(event, channel, user, extra)
  embed(target: channel) do |m|
    m.author = { name: user.distinct, icon_url: user.avatar_url }
    m.title = 'Command execution'

    m.fields = [
      { name: 'Command', value: event.message.to_s.truncate(1024), inline: true },
      { name: 'User ID', value: user.id, inline: true }
    ]

    m.fields << [{ name: 'Information', value: extra }] if extra

    m.timestamp = Time.now
  end
end

def console_log(event, extra = nil)
  QBot.log.info("command execution by #{event.author.distinct} on #{event.server.id}: " \
                "#{event.message}#{extra && "; #{extra}"}")
end

def log(event, extra = nil)
  console_log(event, extra)

  chan_id = ServerConfig.for(event.server.id)[:log_channel_id]
  return unless chan_id

  begin
    lc = event.bot.channel(chan_id)
    log_embed(event, lc, event.author, extra)
  rescue Discordrb::Errors::UnknownChannel
    event.server.owner.pm(t('log-channel-gone'))
  end
end

# Listen for a user response
def user_response(event)
  response = event.bot.add_await!(
    Discordrb::Events::MentionEvent,
    in: event.channel,
    from: event.author
  )

  parse_int(response.message.text.split.first)
end

def unescape(str) = "\"#{str}\"".undump

def cmd_target(event, arg)
  id = arg.to_i

  if id.zero?
    event.message.mentions[0] || event.author
  else
    event.bot.user(id)
  end
end

def to_word(num)
  numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  words = %w[zero one two three four five six seven eight nine ten]
  map = numbers.zip(words).to_h
  map[num] || num
end

##
# Maps a single-digit integer to its corresponding Unicode emoji
def to_emoji(num)
  if num.between?(0, 9)
    # digit + Variation Selector-16 + Combining Enclosing Keycap
    "#{num}\uFE0F\u20E3"
  elsif num == 10
    # Keycap Digit Ten emoji
    "\u{1F51F}"
  else
    raise ArgumentError, "#{num} does not correspond to an emoji"
  end
end

##
# Tries to parse an Integer from a value. Returns nil on failure.
def parse_int(num)
  Integer(num)
rescue ArgumentError, TypeError
  nil
end

##
# Extracts everything past the nth word in a string.
# Uses the same rules as `String#split`.
# Returns nil on error.
def after_nth_word(n_words, str)
  re = /
    \A            # Anchor to start of string
    (?:
      \S+\s+      # Match a word and the spaces after...
    ){#{n_words}} # ...n times
    \K            # Reset match
    .*            # Match everything that comes after
    \z            # Anchor to end of string
  /mx

  str[re]
end
