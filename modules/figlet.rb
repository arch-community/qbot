require 'ruby_figlet'

module Figlet
  extend Discordrb::Commands::CommandContainer

  command :figlet, {
    help_available: true,
    description: 'Renders some text as ASCII art',
    usage: '.figlet <text>',
    min_args: 1
  } do |event, *text|
    input = breaking_word_wrap(text.join(' '), 16)
    figlet = RubyFiglet::Figlet.new(input).to_s

    <<~END
      ```
      #{figlet}
      ```
    END
  end
end
