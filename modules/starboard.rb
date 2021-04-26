# frozen_string_literal: true

# Starboard commands
module Starboard
  extend Discordrb::Commands::CommandContainer
end

# Define functions for embed
## Get author
def embed_author(user)
  {
    icon_url: user.avatar_url,
    name: user.username
  }
end

## Get message attachment
def embed_image(message)
  return unless message.attachments.first

  {
    url: message.attachments.first.url
  }
end

## Get field text
def embed_fields(event)
  [{
    name: 'Message',
    value: format('[#%<name>s](%<link>s)', name: event.channel.name, link: event.message.link)
  }]
end

## Send starboard embed
def send_embed(event, channel)
  # Send starboard embed
  embed(target: channel) do |m|
    m.author = embed_author(event.message.author)
    m.description = event.message.content
    # m.fields = embed_fields(event)
    m.image = embed_image(event.message)
    m.timestamp = event.message.creation_time
  end
end

# Get variables
def fetch_values(config, event)
  [
    config.options['starboard-channel'],
    StarboardEntry.where(message_id: event.message.id).first
  ]
end

# Reaction event handler
QBot.bot.reaction_add do |event|
  scfg = ServerConfig[event.server.id]
  break if scfg.modules_conf['disabled'].include? 'starboard'

  # Get variables from db
  fetch_values(scfg, event) => [starboard, sb_entry]
  emoji_name = (scfg.options['starboard-emoji'] || QBot.config.global.starboard.emoji)
  min = (scfg.options['starboard-minimum'] || QBot.config.global.starboard.minimum_reacts)

  # Handle reactions
  if starboard \
      && !sb_entry \
      && (event.emoji.name == emoji_name) \
      && (event.channel.id != starboard)
    # Get channel from cache
    starboard_channel = event.bot.channel(starboard)
    # Count reactions and reject the author of the message from the count
    rcount = event.message.reacted_with(event.emoji, limit: min + 1).reject do |user|
      user.id == event.message.author.id
    end.length

    if rcount >= min
      starboard_msg = send_embed(event, starboard_channel)
      # Add entry to database
      StarboardEntry.create(message_id: event.message.id,
                            starboard_id: starboard_msg.id,
                            server_id: event.server.id)
    end
  end
end

# Deletion event handler
QBot.bot.message_delete do |event|
  scfg = ServerConfig[event.channel.server.id]
  break if scfg.modules_conf['disabled'].include? 'starboard'

  # Get values from db
  fetch_values(scfg, event) => [starboard, sb_entry]
  delete_msgs = scfg.options['starboard-delete']

  # Handle deletions
  ## Handle starboard message deletion
  if event.channel.id == starboard
    # Delete message from records
    sb_entries = StarboardEntry.where(starboard_id: event.id)
    sb_entries.destroy_all
  ## Handle original message deletion
  elsif delete_msgs && sb_entry
    # Delete message
    starboard_channel = event.bot.channel(starboard)
    starboard_channel.load_message(sb_entry.starboard_id).delete
  end
end
# vim: ts=2:sw=2:set expandtab
