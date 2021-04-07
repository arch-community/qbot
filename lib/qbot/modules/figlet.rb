# frozen_string_literal: true

require 'figlet'

# Text to ASCII art
module Figlet
  extend Discordrb::Commands::CommandContainer


  command :figlet, {
    help_available: true,
    description: 'Renders some text as ASCII art',
    usage: '.figlet <text>',
    min_args: 1
  } do |_, *text|
    font = Figlet::Font.new('standard.flf')
    ts = Figlet::Typesetter.new(font)

    input = QBot.breaking_word_wrap(text.join(' '), 16)
    figlet = ts[input]

    "```\n#{figlet}\n```"
  end
end
