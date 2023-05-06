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
  } do |event, *_|
    text = after_nth_word(1, event.text)
    embed Bottom.encode text
  end

  command :regress, {
    aliases: %i[rg debottom db ub],
    help_available: true,
    usage: '.db <text>',
    min_args: 1
  } do |event, *_|
    input = after_nth_word(1, event.text)
    text = Bottom.decode(input).gsub('@', "\\@\u200D")

    embed text
  end
end
