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
      Config.help_msg 'uc', %i[help language sitelenpona]

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
      uc.contents['sitelenpona'] ||= {}
      case spcmd
      when 'help', nil
        Config.help_msg \
          'uc sitelenpona',
          %i[fgcolor bgcolor fontface fontsize name glyphs]
      when 'fgcolor', 'fg', 'bgcolor', 'bg'
        colortype = spcmd.start_with?('fg') ? :fgcolor : :bgcolor
        default = colortype == :fgcolor ? 'black' : 'white'
        current = uc.contents['sitelenpona'][colortype.to_s] || default

        subcmd = args.shift
        case subcmd
        when 'help', nil
          Config.help_msg "uc sitelenpona #{colortype}", %i[show set reset]
        when 'show', 'sh', 'v'
          embed t('uc.sitelenpona.color.show', colortype, current)
        when 'set', 's'
          confirm = uc.contents['sitelenpona'][colortype.to_s] = args.shift
          uc.save!
          embed t('uc.sitelenpona.color.set', colortype, confirm)
        when 'reset', 'rs'
          confirm = uc.contents['sitelenpona'][colortype.to_s] = default
          uc.save!
          embed t('uc.sitelenpona.color.set', colortype, confirm)
        end
      when 'fontsize', 'size', 'fs', 's'
        subcmd = args.shift
        default = 32
        current = uc.contents['sitelenpona']['fontsize'] || default

        case subcmd
        when 'help', nil
          Config.help_msg 'uc sitelenpona fontsize', %i[show set reset]
        when 'show', 'sh', 'v'
          embed t('uc.sitelenpona.fontsize.show', current)
        when 'set', 's'
          confirm = uc.contents['sitelenpona']['fontsize'] = args.shift.to_i
          uc.save!
          embed t('uc.sitelenpona.fontsize.set', confirm)
        when 'reset', 'rs'
          confirm = uc.contents['sitelenpona']['fontsize'] = default
          uc.save!
          embed t('uc.sitelenpona.fontsize.set', confirm)
        end
      when 'fontface', 'font', 'ff', 'f'
        subcmd = args.shift
        default = 'linja suwi'
        current = uc.contents['sitelenpona']['fontface'] || default

        case subcmd
        when 'help', nil
          Config.help_msg 'uc sitelenpona fontface', %i[show set reset]
        when 'show', 'sh', 'v'
          embed t('uc.sitelenpona.fontface.show', current)
        when 'list', 'ls', 'l'
          list = SPGen.font_metadata
                      .map.with_index { |info, idx| "[#{idx}] #{info[:typeface]}" }
                      .join("\n")

          embed "```#{list}```"
        when 'set', 's'
          index = begin
                    Integer(args.shift)
                  rescue
                    false
                  end

          if index && (font = SPGen.font_metadata[index])
            confirm = uc.contents['sitelenpona']['fontface'] = font[:typeface]
            uc.save!
            embed t('uc.sitelenpona.fontface.set', confirm)
          else
            embed t('uc.sitelenpona.fontface.invalid')
          end
        when 'reset', 'rs'
          confirm = uc.contents['sitelenpona']['fontface'] = default
          uc.save!
          embed t('uc.sitelenpona.fontface.set', confirm)
        end
      when 'name', 'n'
        subcmd = args.shift
        default = event.user.nickname
        current = uc.contents['sitelenpona']['name'] || default

        case subcmd
        when 'help', nil
          Config.help_msg 'uc sitelenpona name', %i[show set reset]
        when 'show', 'sh', 'v'
          embed t('uc.sitelenpona.name.show', current)
        when 'set', 's'
          confirm = uc.contents['sitelenpona']['name'] = args.join(' ')
          uc.save!
          embed t('uc.sitelenpona.name.set', confirm)
        when 'reset', 'rs'
          confirm = uc.contents['sitelenpona']['name'] = default
          uc.save!
          embed t('uc.sitelenpona.name.set', confirm)
        end
      when 'glyphs', 'g'
        subcmd = args.shift
        default = nil
        current = uc.contents['sitelenpona']['glyphs'] || default

        case subcmd
        when 'help', nil
          Config.help_msg 'uc sitelenpona glyphs', %i[show set reset]
        when 'show', 'sh', 'v'
          embed t('uc.sitelenpona.glyphs.show', current)
        when 'set', 's'
          confirm = uc.contents['sitelenpona']['glyphs'] = args.join(' ')
          uc.save!
          embed t('uc.sitelenpona.glyphs.set', confirm)
        when 'reset', 'rs'
          confirm = uc.contents['sitelenpona']['glyphs'] = default
          uc.save!
          embed t('uc.sitelenpona.glyphs.set', confirm)
        end
      end

    else
      embed t('cfg.nyi')
    end
  end
end
