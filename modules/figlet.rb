# frozen_string_literal: true

require 'ruby_figlet'

# Text to ASCII art
module Figlet
  extend Discordrb::Commands::CommandContainer

  command :figlet, {
    help_available: true,
    usage: '.figlet <text>',
    min_args: 1
  } do |event, *_|
    text = after_nth_word(1, event.text)
    input = QBot.breaking_word_wrap(text, 16)

    lines = input.lines.map { RubyFiglet::Figlet.new(_1).to_s }

    fence = "```\n"
    lines.last << fence

    char_limit = 2000

    msgs = lines.each_with_object([fence.dup]) { |line, acc|
      # would ending the message here cause it to go over the character limit?
      if (acc.last.size + line.size + "\n".size + fence.size) > char_limit
        # if so, start a new message
        acc.last << fence
        acc << fence.dup
      end

      acc.last << line << "\n"
    }

    max = 3
    next embed t('figlet.too-long', msgs.count, max) if msgs.count > max

    msgs.each { event.respond _1 }
  end
end
