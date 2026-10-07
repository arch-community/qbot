# frozen_string_literal: true

# Various linguistics-related commands
module Languages
  extend Discordrb::Commands::CommandContainer

  command :ipa, {
    help_available: true,
    usage: '.ipa <text>',
    min_args: 1
  } do |event, *_|
    text = args_after(event)

    # fix mention escapes
    text.gsub!('\\@', '@')

    embed XSConverter.convert(text)
  end
end
