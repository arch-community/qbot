# frozen_string_literal: true

# User config command module
module Admin
  extend Discordrb::Commands::CommandContainer

  command :userconfig, {
    aliases: [:ucfg, :uc],
    help_available: true,
    description: 'Allows users to configure various settings',
    usage: '.set <args>',
    min_args: 0
  } do |event, *args|
    command = args.shift

    case command
    when 'help', ''
      Config.help_msg event, 'uc', {
        help: 'show this message',
        language: 'set the language the bot uses with you'
      }

    when 'language', 'lang'
      subcmd = args.shift
      case subcmd
      when 'help', ''
        Config.help_msg event, 'uc language', {
          list: 'show available languages',
          set: 'change your user language',
          reset: 'change your user language to English'
        }

      when 'list', 'l'

      when 'set', 's'

      when 'reset', 'rs'

      end
        
    else
      embed event, 'Not yet implemented!'
    end
  end
end
