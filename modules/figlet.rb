# frozen_string_literal: true

require 'ruby_figlet'

# Text to ASCII art
module Figlet
  extend Discordrb::Commands::CommandContainer

  command :figlet, {
    help_available: true,
    usage: '.figlet <text>',
    min_args: 1
  } do |_event, *text|
    input = BreakingWordWrap.breaking_word_wrap(text.join(' '), line_width: 16)
    figlet = RubyFiglet::Figlet.new(input).to_s

    "```\n#{figlet}\n```"
  end
end
