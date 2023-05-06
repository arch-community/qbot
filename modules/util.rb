# frozen_string_literal: true

# Utility commands
module Util
  extend Discordrb::Commands::CommandContainer

  command :echo, {
    help_available: true,
    usage: '.echo <string>',
    min_args: 1
  } do |event, *_|
    text = after_nth_word(1, event.text)

    event.respond_wrapped(text, allowed_mentions: false)
  end

  command :botrepo, {
    help_available: true,
    usage: '.mygit',
    min_args: 0,
    max_args: 0
  } do
    QBot.config.my_repo
  end

  def self.full_avatar(user)
    url = user.avatar_url

    full_url = url.end_with?('.gif') ? url : user.avatar_url('png')

    "#{full_url}?size=1024"
  end

  command :avatar, {
    help_available: true,
    usage: '.avatar',
    min_args: 0,
    max_args: 1
  } do |event, user|
    target_user = cmd_target(event, user)

    event.respond(full_avatar(target_user))
  end

  command :invite, {
    help_available: true,
    usage: '.invite',
    min_args: 0,
    max_args: 0
  } do |event|
    me = event.bot.bot_user

    embed do |m|
      m.title = t('util.invite.title', me.username)

      m.description = t(
        'util.invite.desc',
        me.username,
        event.bot.invite_url(permission_bits: '339078224')
      )

      m.thumbnail = { url: me.avatar_url }
    end
  end

  command :slowmode, {
    help_available: true,
    usage: '.slowmode [time]',
    min_args: 0,
    max_args: 1,
    arg_types: [Integer],
    required_permissions: %i[manage_messages]
  } do |event, time|
    if time
      event.channel.slowmode_rate = time
      embed t('util.slowmode.set_rate', time)
    else
      embed t('util.slowmode.get_rate', event.channel.slowmode_rate)
    end
  end

  command :voicekick, {
    help_available: true,
    usage: '.voicekick [user] [channel]',
    min_args: 1,
    max_args: 2
  } do |event, user, channel|
    can_kick = event.author.permission?(:move_members, event.channel)
    next event.respond t('no_perms') unless can_kick

    target_channel = channel || event.server.afk_channel
    next embed.respond t('util.voicekick.failure') unless target_channel

    target_user = cmd_target(event, user)
    event.server.move(target_user, target_channel)
    event.respond t('util.voicekick.success')
  end
end
