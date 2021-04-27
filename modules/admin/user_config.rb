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
    uc = UserConfig[event.user.id]

    case command
    when 'help', nil
      Config.help_msg 'uc', %i[help language]

    when 'language', 'lang', 'l'
      subcmd = args.shift
      case subcmd
      when 'help', nil
        Config.help_msg 'uc language', %i[list set reset]

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

    when 'sitelenpona', 'sp'
      spcmd = args.shift
      case spcmd
      when 'help', nil
        Config.help_msg \
          'uc sitelenpona',
          %i[fgcolor bgcolor font-face font-size name name-glyphs]
      when 'fgcolor', 'fg', 'bgcolor', 'bg'
        colortype = spcmd.start_with?('fg') ? :fgcolor : :bgcolor
        default = (colortype == :fgcolor) ? 'black' : 'white'
        current = uc['sitelenpona'][colortype.to_s] || default

        subcmd = args.shift
        case subcmd
        when 'help', nil
          Config.help_msg "uc sitelenpona #{colortype}", %i[show set reset]
        when 'show'
          embed t("uc.sitelenpona.color.show", colortype, current)
        when 'set'
          confirm = uc['sitelenpona'][colortype.to_s] = args.shift
          embed t('uc.sitelenpona.color.set', colortype, confirm)
        when 'reset'
          confirm = uc['sitelenpona'][colortype.to_s] = default
          embed t('uc.sitelenpona.color.set', colortype, confirm)
        end
      when 'font-size', 'size', 'fs', 's'
      when 'font-face', 'font', 'ff', 'f'
      when 'name', 'n'
      when 'name-glyphs', 'ng'
      end

    else
      embed t('cfg.nyi')
    end
  end
end
