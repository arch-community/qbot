# frozen_string_literal: true

# Utility commands
module Util
  extend Discordrb::Commands::CommandContainer

  command :echo, {
    help_available: true,
    usage: '.echo <string>',
    min_args: 1
  } do |event, *args|
    event.respond_wrapped args.join(' '), allowed_mentions: false
  end

  command :botrepo, {
    help_available: true,
    usage: '.mygit',
    min_args: 0,
    max_args: 0
  } do |event|
    event.bot.config.my_repo
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

    event.respond Util.full_avatar(target_user)
  end

  command :invite, {
    help_available: true,
    usage: '.invite',
    min_args: 0,
    max_args: 0
  } do |event|
    b = event.bot
    u = b.bot_user

    embed do |m|
      m.title = t('util.invite.title', u.username)
      m.description = t('util.invite.desc',
                        u.username, b.invite_url(permission_bits: '339078224'))
      m.thumbnail = { url: u.avatar_url }
    end
  end

  command :slowmode, {
    help_available: true,
    usage: '.slowmode [time]',
    min_args: 0,
    max_args: 1,
    arg_types: [Integer],
    required_permissions: %i[manage_channels]
  } do |event, time|
    if time
      event.channel.slowmode_rate = time
    else
      event.respond event.channel.slowmode_rate
    end
  end
end
