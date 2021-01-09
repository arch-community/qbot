# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
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
    log(event)

    return t(:no_perms) unless event.author.permission?(:administrator)

    command = args.shift

    case command
    when 'help', nil
      Config.help_msg event, 'cfg', %i[
        help log-channel modules prefix extra-color-role
        snippet rolegroup reaction blacklist
      ]

    when 'log-channel', 'lc'
      cfg = Config[event.server.id]
      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg log-channel', %i[set reset]
      when 'set'
        new_id = args.shift.to_i

        cfg.log_channel_id = new_id
        cfg.save!

        embed event, t('cfg.log-channel.set.success', new_id)

      when 'reset'
        cfg.log_channel_id = nil
        cfg.save!

        embed event, t('cfg.log-channel.reset.success')
      end

    when 'prefix', 'pfx'
      cfg = Config[event.server.id]
      subcmd = args.shift

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg prefix', %i[set reset]
      when 'set'
        Config.save_prefix event, cfg, args.join(' ')
      when 'reset'
        Config.save_prefix event, cfg, QBot.config.global.prefix || '.'
      end

    when 'extra-color-role', 'ecr'
      subcmd = args.shift
      role_id = args.shift.to_i

      case subcmd
      when 'help', nil
        Config.help_msg event, 'cfg extra-color-role', %i[list add remove]

      when 'list'
        role_rows = ExtraColorRole.where(server_id: event.server.id)
        if role_rows.empty?
          embed event, t('cfg.extra-color-role.list.no-roles')
          return
        end

        roles = role_rows.map { event.server.role(_1.role_id.to_i) }

        role_descriptions = roles.map {
          hex = _1.color.hex.rjust(6, '0')
          "##{hex} #{_1.id} #{_1.name}"
        }.join("\n")

        embed event, "```#{role_descriptions}```"

      when 'add'
        role = event.server.role(role_id)
        unless role
          embed event, t('cfg.extra-color-role.add.not-found')
          return
        end

        begin
          ExtraColorRole.create(server_id: event.server.id, role_id: role_id)
        rescue ActiveRecord::RecordNotUnique
          embed event, t('cfg.extra-color-role.add.non-unique')
          return
        end

        embed event, t('cfg.extra-color-role.add.success', role.name, role.id)

      when 'remove', 'del', 'rm'
        ExtraColorRole.where(role_id: role_id).delete_all

        embed event, t('cfg.extra-color-role.remove.success', role_id)
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
          embed event, t('cfg.snippet.add.non-unique', name)
          return
        end

        Snippet.create(server_id: event.server.id,
                       name: name,
                       text: text,
                       embed: true)

        embed event, t('cfg.snippet.add.success', name)

      when 'edit', 'set', 'e', 's'
        name = args.shift
        text = args.join(' ').gsub('\n', "\n")

        if (snippet = Snippet.find_by(server_id: event.server.id, name: name))
          snippet.text = text
          snippet.save!

          embed event, t('cfg.snippet.edit.success', name)
        else
          embed event, t('cfg.snippet.edit.not-found', name)
          return
        end

      when 'remove', 'rm', 'delete', 'd'
        name = args.shift
        Snippet.where(server_id: event.server.id, name: name).delete_all
        embed event, t('cfg.snippet.remove.success', name)

      when 'prop', 'p'
        name = args.shift

        if name == 'help'
          Config.help_msg event, 'cfg snippet prop', %i[embed]
          return
        end

        snippet = Snippet.find_by(server_id: event.server.id, name: name)
        unless snippet
          embed event, t('cfg.snippet.edit.not-found', name)
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

        embed event, t('cfg.snippet.prop.success', subcmd, name, prop)

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

        embed event, t('cfg.blacklist.add.success', entry.id)

      when 'remove', 'delete', 'rm', 'd'
        id = args.shift.to_i

        begin
          entry = BlacklistEntry.find(id)
          if entry.server_id == event.server.id
            entry.destroy!
            embed event, t('cfg.blacklist.remove.success', id)
          else
            embed event, t('cfg.blacklist.remove.wrong-server', id)
          end
        rescue ActiveRecord::RecordNotFound
          embed event, t('cfg.blacklist.remove.not-found', id)
        end

      when 'list', 'l'
        bl = BlacklistEntry.where(channel_id: channel_id)

        event.channel.send_embed do |m|
          m.title = t('cfg.blacklist.list.title')
          m.description = bl.map { "`#{_1.id}`: `#{_1.regex}`" }.join("\n")
        end

      when 'clear'
        bl = BlacklistEntry.where(channel_id: channel_id)
        count = bl.size
        bl.delete_all

        embed event, t('cfg.blacklist.clear.success', count)

      end

    else
      embed event, t('cfg.nyi')

    end
  end
  # rubocop: enable Metrics/BlockLength
end
# rubocop: enable Metrics/ModuleLength
