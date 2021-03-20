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

    embed do |m|
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

  uc = UserConfig[event.user.id]
  lang = uc.contents && uc.contents['lang']&.to_sym || I18n.default_locale
  I18n.locale = lang

  contents = event.message.text

  bl = BlacklistEntry
       .where(channel_id: event.channel.id)
       .filter { |entry| entry.re.match? event.message.text }
       .first

  if bl
    event.message.author.pm t('blacklist.message', bl.re, contents)
    event.message.delete
  end
end
