# frozen_string_literal: true

##
# Fun commmands
module Fun
  extend Discordrb::Commands::CommandContainer
end

QBot.bot.mention do |event|
  event.respond(QBot.config.ping_emote || t('fun.ping'))
end
