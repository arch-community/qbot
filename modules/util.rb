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

  command :mygit, {
    help_available: true,
    description: 'Posts the URL of my Git repo',
    usage: '.mygit',
    min_args: 0,
    max_args: 0
  } do |event|
    $config.my_repo
  end
end
