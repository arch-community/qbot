# frozen_string_literal: true

module Bottom
  extend Discordrb::Commands::CommandContainer
  
  command :bottom, {
    aliases: [:b],
    help_available: true,
    usage: '.b <text>',
    min_args: 1
  } do |event, *args|
    text = args.join(' ').gsub('@', "\\@\u200D")
    embed Bottom.encode text
  end

  command :debottom, {
    aliases: [:db, :ub],
    help_available: true,
    usage: '.db <text>',
    min_args: 1
  } do |event, *args|
    input = args.join(' ')
    text = Bottom.decode(input).gsub('@', "\\@\u200D")
    embed text
  end
end
