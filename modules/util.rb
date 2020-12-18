# frozen_string_literal: true

# Utility commands
module Util
  extend Discordrb::Commands::CommandContainer

  command :echo, {
    help_available: true,
    description: 'Echoes a string',
    usage: '.echo <string>',
    min_args: 1
  } do |event, *args|
    log(event)
    args.join(' ').gsub('@', "\\@\u200D")
  end

  command :botrepo, {
    help_available: true,
    description: 'Posts the URL of the bot\'s Git repo',
    usage: '.mygit',
    min_args: 0,
    max_args: 0
  } do |event|
    log(event)
    QBot.config.my_repo
  end

  command :avatar, {
    help_available: true,
    description: 'Posts the URL of a user\'s avatar',
    usage: '.avatar',
    min_args: 0,
    max_args: 1
  } do |event, user|
    log(event)

    if (id = user.to_i) != 0
      event.respond event.bot.user(id).avatar_url
    elsif event.message.mentions[0]
      event.respond event.message.mentions[0].avatar_url
    else
      event.respond event.author.avatar_url
    end
  end
end
