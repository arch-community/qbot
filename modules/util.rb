# frozen_string_literal: true

# Utility commands
module Util
  extend Discordrb::Commands::CommandContainer

  command :echo, {
    help_available: true,
    usage: '.echo <string>',
    min_args: 1
  } do |event, *args|
    log(event)
    args.join(' ').gsub('@', "\\@\u200D")
  end

  command :botrepo, {
    help_available: true,
    usage: '.mygit',
    min_args: 0,
    max_args: 0
  } do |event|
    log(event)
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
    log(event)

    target_user = cmd_target(event, user)

    event.respond Util.full_avatar(target_user)
  end
end
