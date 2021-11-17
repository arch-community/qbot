# frozen_string_literal: true

##
# uwu?
module Bottom
  extend Discordrb::Commands::CommandContainer

  command :bottom, {
    aliases: %i[b],
    help_available: true,
    usage: '.b <text>',
    min_args: 1
  } do |_, *args|
    text = args.join(' ').gsub('@', "\\@\u200D")
    embed Bottom.encode text
  end

  command :regress, {
    aliases: %i[rg debottom db ub],
    help_available: true,
    usage: '.regress <text>',
    min_args: 1
  } do |_, *args|
    input = args.join(' ')
    text = Bottom.decode(input).gsub('@', "\\@\u200D")
    embed text
  end
end
