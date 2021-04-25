# frozen-string-literal: true

# Remove !'s from nicknames
module Nicknames
  extend Discordrb::Commands::CommandContainer
end

QBot.bot.member_update do |event|
  sc = ServerConfig[event.server.id]
  break if sc.modules_conf['disabled'].include? 'nicknames'

  if event.user.nick[0] == '!'
    begin
      event.user.set_nick("#{event.user.nick.match(/^!*(.*)$/)[1]}z")
    rescue Discordrb::Errors::NoPermission
      # Alert the owner about not being able to change the nickname due to missing permissions
      suppress(Discordrb::Errors::NoPermission) do
        # And hope that they don't have the bot blocked or dms off
        event.server.owner.pm t('nicknames.missing-permissions', event.user.username)
      end
    else
      suppress(Discordrb::Errors::NoPermission) do
        event.user.pm t('nicknames.moderated')
      end
    end
  end
end

QBot.bot.member_join do |event|
  sc = ServerConfig[event.server.id]
  break if sc.modules_conf['disabled'].include? 'nicknames'

  if event.user.username[0] == '!'
    begin
      event.user.set_nick("#{event.user.username.match(/^!*(.*)$/)[1]}z")
      event.user.pm t('nicknames.moderated')
    rescue Discordrb::Errors::NoPermission
      suppress(Discordrb::Errors::NoPermission) do
        event.server.owner.pm t('nicknames.missing-permissions', event.user.username)
      end
    else
      suppress(Discordrb::Errors::NoPermission) do
        event.user.pm t('nicknames.moderated')
      end
    end
  end
end
