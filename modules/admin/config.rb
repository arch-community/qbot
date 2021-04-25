# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength, Metrics/BlockNesting
# Configuration command for the admin module.
module Admin
  extend Discordrb::Commands::CommandContainer

  # rubocop: disable Metrics/BlockLength
  command :config, {
    aliases: [:cfg],
    help_available: true,
    usage: '.cfg <args>',
    min_args: 0
  } do |event, *args|
    unless event.author.permission?(:administrator)
      embed t(:no_perms)
      return
    end

    cfg = ServerConfig[event.server.id]

    command = args.shift

    case command
    when 'help', nil
      Config.help_msg event, 'cfg', %i[
        help log-channel modules prefix colors
        snippet rolegroup reaction blacklist misc
		starboard
      ]

    when 'log-channel', 'lc'
      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg log-channel', %i[set reset]
      when 'set'
        new_id = args.shift.to_i

        cfg.log_channel_id = new_id
        cfg.save!

        embed t('cfg.log-channel.set.success', new_id)

      when 'reset'
        cfg.log_channel_id = nil
        cfg.save!

        embed t('cfg.log-channel.reset.success')
      end

    when 'prefix', 'pfx'
      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg prefix', %i[set reset]
      when 'set'
        Config.save_prefix event, cfg, args.join(' ')
      when 'reset'
        Config.save_prefix event, cfg, QBot.config.global.prefix || '.'
      end

    when 'colors', 'c'
      subcmd = args.shift
      case subcmd
      when 'help', 'h', nil
        Config.help_msg event, 'cfg colors', %i[extra-color-role bare-colors]
      when 'extra-color-role', 'ecr'
        opt = args.shift
        role_id = args.shift.to_i

        case opt
        when 'help', nil
          Config.help_msg event, 'cfg colors extra-color-role', %i[list add remove]

        when 'list'
          role_rows = ExtraColorRole.where(server_id: event.server.id)
          if role_rows.empty?
            embed t('cfg.colors.extra-color-role.list.no-roles')
            return
          end

          roles = role_rows.map { event.server.role(_1.role_id.to_i) }

          role_descriptions = roles.map {
            hex = _1.color.hex.rjust(6, '0')
            "##{hex} #{_1.id} #{_1.name}"
          }.join("\n")

          embed "```#{role_descriptions}```"

        when 'add'
          role = event.server.role(role_id)
          unless role
            embed t('cfg.colors.extra-color-role.add.not-found')
            return
          end

          begin
            ExtraColorRole.create(server_id: event.server.id, role_id: role_id)
          rescue ActiveRecord::RecordNotUnique
            embed t('cfg.colors.extra-color-role.add.non-unique')
            return
          end

          embed t('cfg.colors.extra-color-role.add.success', role.name, role.id)

        when 'remove', 'del', 'rm'
          ExtraColorRole.where(role_id: role_id).delete_all

          embed t('cfg.colors.extra-color-role.remove.success', role_id)
        end

      when 'bare-colors', 'bc'
        opt = args.shift

        case opt
        when 'help', nil
          Config.help_msg event, 'cfg colors bare-colors', %i[enable disable show]

        when 'enable', 'on', 'true', 't'
          cfg.options['bare-colors'] = true
          cfg.save!
          embed t('cfg.colors.bare-colors.toggled-on')

        when 'disable', 'off', 'false', 'f'
          cfg.options['bare-colors'] = false
          cfg.save!
          embed t('cfg.colors.bare-colors.toggled-off')

        when 'show', 'view'
          opt = cfg.options['bare-colors'] ? 'true' : 'false'

          embed t('cfg.colors.bare-colors.show', opt)
        end
      end

    when 'snippet', 's'
      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg snippet', %i[list add remove set]

      when 'list', 'l'
        QBot.bot.execute_command(:listsnippets, event, [])

      when 'add', 'a'
        name = args.shift
        text = args.join(' ').gsub('\n', "\n")

        if Snippet.find_by(server_id: event.server.id, name: name)
          embed t('cfg.snippet.add.non-unique', name)
          return
        end

        Snippet.create(server_id: event.server.id,
                       name: name,
                       text: text,
                       embed: true)

        embed t('cfg.snippet.add.success', name)

      when 'edit', 'set', 'e', 's'
        name = args.shift
        text = args.join(' ').gsub('\n', "\n")

        if (snippet = Snippet.find_by(server_id: event.server.id, name: name))
          snippet.text = text
          snippet.save!

          embed t('cfg.snippet.edit.success', name)
        else
          embed t('cfg.snippet.edit.not-found', name)
          return
        end

      when 'remove', 'rm', 'delete', 'd'
        name = args.shift
        Snippet.where(server_id: event.server.id, name: name).delete_all
        embed t('cfg.snippet.remove.success', name)

      when 'prop', 'p'
        name = args.shift

        if name == 'help'
          Config.help_msg event, 'cfg snippet prop', %i[embed]
          return
        end

        snippet = Snippet.find_by(server_id: event.server.id, name: name)
        unless snippet
          embed t('cfg.snippet.edit.not-found', name)
          return
        end

        subcmd = args.shift
        prop = nil

        case subcmd
        when 'embed', 'm'
          prop = ActiveModel::Type::Boolean.new.cast(args.shift)
          snippet.embed = prop
          snippet.save!
        end

        embed t('cfg.snippet.prop.success', subcmd, name, prop)

      end

    when 'blacklist', 'bl'

      channel_id = if args[0].to_i != 0
                     args.shift.to_i
                   else
                     event.channel.id
                   end

      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg blacklist [channel]', %i[add remove list clear]

      when 'add', 'a'
        entry = BlacklistEntry.create(server_id: event.server.id,
                                      channel_id: event.channel.id,
                                      regex: args.join(' '))

        embed t('cfg.blacklist.add.success', entry.id)

      when 'remove', 'delete', 'rm', 'd'
        id = args.shift.to_i

        begin
          entry = BlacklistEntry.find(id)
          if entry.server_id == event.server.id
            entry.destroy!
            embed t('cfg.blacklist.remove.success', id)
          else
            embed t('cfg.blacklist.remove.wrong-server', id)
          end
        rescue ActiveRecord::RecordNotFound
          embed t('cfg.blacklist.remove.not-found', id)
        end

      when 'list', 'l'
        bl = BlacklistEntry.where(channel_id: channel_id)

        embed do |m|
          m.title = t('cfg.blacklist.list.title')
          m.description = bl.map { "`#{_1.id}`: `#{_1.regex}`" }.join("\n")
        end

      when 'clear'
        bl = BlacklistEntry.where(channel_id: channel_id)
        count = bl.size
        bl.delete_all

        embed t('cfg.blacklist.clear.success', count)

      end

    when 'starboard', 'sb'
      subcmd = args.shift
      case subcmd
      when 'help', 'h', nil
        Config.help_msg event, 'cfg starboard', %i[emoji minimum-reacts channel delete-msgs]
      when 'emoji', 'e'
        unless event.message.emoji?
          embed t('cfg.starboard.emoji.none-provided')
          break
        end
        opt = event.message.emoji.first.name
        cfg.options['starboard-emoji'] = opt
        embed t('cfg.starboard.emoji.success', opt)
      when 'minimum-reacts', 'min', 'm'
        opt = args.shift.first.to_i
        unless opt > 0
          embed t('cfg.starboard.minimum-reacts.too-low')
          break
        end
        cfg.options['starboard-minimum'] = opt
        embed t('cfg.starboard.minimum-reacts.success', opt)
      when 'channel', 'c'
        opt = event.bot.channel(args.shift)
        unless opt
          embed t('cfg.starboard.channel.invalid-channel')
          break
        end
        cfg.options['starboard-channel'] = opt.id
        embed t('cfg.starboard.channel.success', opt.mention)
      when 'delete-messages', 'delete', 'd'
        opt = ActiveModel::Type::Boolean.new.cast(args.shift)
        cfg.options['starboard-delete'] = opt
        embed t('cfg.starboard.delete.success', opt)
      end

    when 'misc', 'm'
      subcmd = args.shift
      cfg.options ||= {}

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg misc', %i[]
      end

    else
      embed t('cfg.nyi')

    end
  end
  # rubocop: enable Metrics/BlockLength
end
# rubocop: enable Metrics/ModuleLength, Metrics/BlockNesting
# vim: ts=2:sw=2:set expandtab
