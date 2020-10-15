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
end
