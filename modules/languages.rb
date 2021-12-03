# frozen_string_literal: true

# Various linguistics-related commands
module Languages
  extend Discordrb::Commands::CommandContainer

  command :ipa, {
    help_available: true,
    usage: '.ipa <text>',
    min_args: 1
  } do |_, *args|
    text = args.join(' ').gsub('\\@', '@')

    embed XSConverter.convert(text)
  end
end
