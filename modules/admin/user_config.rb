# frozen_string_literal: true

# User config command module
module Admin
  extend Discordrb::Commands::CommandContainer

  command :userconfig, { # rubocop: disable Metrics/BlockLength
    aliases: %i[ucfg uc],
    help_available: true,
    usage: '.set <args>',
    min_args: 0
  } do |event, *args|
    command = args.shift

    case command
    when 'help', nil
      Config.help_msg event, 'uc', %i[help language]

    when 'language', 'lang', 'l'
      uc = UserConfig[event.user.id]

      subcmd = args.shift
      case subcmd
      when 'help', nil
        Config.help_msg event, 'uc language', %i[list set reset]

      when 'list', 'l'
        embed do |m|
          m.title = t 'uc.language.list.title'
          m.description = I18n.available_locales.map(&:to_s).join(', ')
        end

      when 'set', 's'
        lang = args.shift
        if I18n.available_locales.map(&:to_s).include? lang
          uc.contents['lang'] = lang
          uc.save!
          I18n.locale = lang.to_sym
          embed t('uc.language.set.success', lang)
        else
          embed t('uc.language.set.not-found', lang)
        end

      when 'reset', 'rs'
        lang = I18n.default_locale.to_s

        uc.contents['lang'] = lang
        uc.save!

        embed t('uc.language.reset.success', lang)
      end

    else
      embed t('cfg.nyi')
    end
  end
end
