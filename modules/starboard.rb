# frozen_string_literal: true

# Starboard commands
module Starboard
	extend Discordrb::Commands::CommandContainer
end

# Reaction event handler
QBot.bot.reaction_add do |event|
	scfg = ServerConfig[event.server.id]
	if scfg.modules_conf['disabled'].include? 'starboard'
		break
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
		if message.attachments.first
			image = {
				url: message.attachments.first.url
			}
		else
			image = nil
		end
		image
	end
	## Get field text
	def embed_fields(event)
		[{
			name: "Message",
			value: format("[#%s](%s)", event.channel.name, event.message.link)
		}]
	end

	# Get variables from db
	## TODO: Settings support
	emoji_name = (nil ? nil : QBot.config.global.starboard.emoji)
	min = (nil ? nil : QBot.config.global.starboard.minimum)
	starboard = 835525656611389450
	starboard_channel = event.bot.channel(starboard)
	sb_entry = StarboardEntry.where(message_id: event.message.id)
	# Handle reactions
	if (starboard) \
			&& (event.emoji.name == emoji_name) \
			&& !(sb_entry) \
			&& (event.channel.id != starboard)
		# Count reactions
		rcount = event.message.reacted_with(event.emoji, limit: min).length
		if rcount >= min
			# Send starboard embed
			## Create embed
			embed_msg = embed(target: starboard_channel) do |m|
				m.author = embed_author(event.message.author)
				m.description = event.message.content
				#m.fields = embed_fields(event)
				m.image = embed_image(event.message)
				m.footer = {text: event.message.id}
				m.timestamp = event.message.creation_time
			end
			## Send embed
			starboard_msg = embed_msg
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
	if scfg.modules_conf['disabled'].include? 'starboard'
		break
	end

	# Get settings from db
	## TODO: Replace nil with setting values
	delete_msgs = (nil ? nil : false)
	starboard = 835509994828464129
	starboard_channel = event.bot.channel(starboard)

	# Handle deletions
	## Handle starboard message deletion
	if event.channel.id == starboard
		# Delete message from records
		sb_entries = StarboardEntry.where(starboard_id: event.id)
		sb_entries.destroy_all
	## Handle original message deletion
	else delete_msgs
		# Delete message
		sb_entry = StarboardEntry.where(message_id: event.id).first
		starboard_channel.load_message(sb_entry.starboard_id).delete
	end
end

