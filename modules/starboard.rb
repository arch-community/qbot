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
	starboard = event.bot.channel("835525656611389450")
	sbmsg = StarboardEntry.where(message_id: event.message.id)
	# Handle reactions
	## TODO: See if db has message
	if (starboard) \
			&& (event.emoji.name == emoji_name) \
			&& !(sbmsg) \
			&& (event.message.channel != starboard)
		# Count reactions
		rcount = event.message.reacted_with(event.emoji, limit: min).length
		if rcount >= min
			# Send starboard embed
			## Create embed
			embed_msg = embed(target: starboard) do |m|
				m.author = embed_author(event.message.author)
				m.description = event.message.content
				m.image = embed_image(event.message)
				m.footer = {text: event.message.id}
				m.timestamp = event.message.creation_time
			end
			## Send embed
			embed_msg
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
	starboard = event.bot.channel("835509994828464129")

	## TODO: Delete entries from db if starboard msg was deleted
	# Handle deletions
	## Handle starboard message deletion
	if event.channel.id == starboard.id
		# Delete message from records
		## TODO: Get message using footer_text& to delete activerecord entry
		sbmsg = StarboardEntry.where(starboard_id: event.id)
		sbmsg.destroy
	end
	## Handle original message deletion
	if delete_msgs ### TODO: Get setting of delete or not
		# Delete message
		sbmsg = StarboardEntry.where(message_id: event.id)
		# TODO: Set up the database models to delete the message
		event.bot.channel("835509994828464129").load_message(sbmsg.starboard_id).delete
		sbmsg.destroy
	end
end

