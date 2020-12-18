# frozen_string_literal: true

# Configuration command for the admin module.
module Admin
  extend Discordrb::Commands::CommandContainer

  # rubocop: disable Metrics/BlockLength
  command :config, {
    aliases: [:cfg],
    help_available: true,
    description: 'Sets various configuration options for the bot',
    usage: '.cfg <args>',
    min_args: 0
  } do |event, *args|
    log(event)

    return 'You do not have the required permissions for this.' unless event.author.permission?(:administrator)

    command = args.shift

    case command
    when 'help', ''
      Config.help_msg event, 'cfg', {
        help: 'show this message',
        'log-channel': 'log bot events to a specific channel',
        modules: 'enable or disable modules',
        prefix: 'set the command prefix for this server',
        'extra-color-role': 'configure extra color roles',
        snippet: 'add, remove, or modify snippets for this server',
        'rolegroup': 'manage groups of self-assignable roles',
        'reaction': 'configure reaction actions'
      }

    when 'log-channel', 'lc'
      cfg = Config[event.server.id]
      subcmd = args.shift

      case subcmd
      when 'help', ''
        Config.help_msg event, 'cfg log-channel', {
          set: 'set the log channel ID for this server',
          reset: 'disable logging to a channel'
        }
      when 'set'
        new_id = args.shift.to_i

        cfg.log_channel_id = new_id
        cfg.save!

        embed event, "The log channel is now <##{new_id}>."

      when 'reset'
        cfg.log_channel_id = nil
        cfg.save!

        embed event, 'The log channel has been disabled.'
      end

    when 'prefix', 'pfx'
      cfg = Config[event.server.id]
      subcmd = args.shift

      case subcmd
      when 'help', ''
        Config.help_msg event, 'cfg prefix', {
          set: 'set the prefix for this server',
          reset: 'resets the prefix to the default'
        }
      when 'set'
        Config.save_prefix event, cfg, args.shift
      when 'reset'
        Config.save_prefix event, cfg, QBot.config.global.prefix || '.'
      end

    when 'extra-color-role', 'ecr'
      subcmd = args.shift
      role_id = args.shift.to_i

      case subcmd
      when 'help', ''
        Config.help_msg event, 'cfg extra-color-role', {
          list: 'print the list of extra color roles',
          add: 'add a role (by ID) to the list of extra roles',
          remove: 'remove a role (by ID) from the list of extra roles'
        }

      when 'list'
        role_rows = ExtraColorRole.where(server_id: event.server.id)
        if role_rows.empty?
          embed event, 'No extra color roles configured yet.'
          return
        end

        roles = role_rows.map { event.server.role(_1.role_id.to_i) }

        role_descriptions = roles.map {
          hex = _1.color.hex.rjust(6, '0')
          "##{hex} #{_1.id} #{_1.name}"
        }.join(?\n)

        embed event, "```#{role_descriptions}```"

      when 'add'
        role = event.server.role(role_id)
        if !role
          embed event, 'Role not found'
          return
        end

        begin
          ExtraColorRole.create(server_id: event.server.id, role_id: role_id)
        rescue ActiveRecord::RecordNotUnique
          embed event, 'That role is already in the list.'
          return
        end

        embed event, "Role `#{role.name}` (`#{role.id}`) added to the list of extra color roles."

      when 'remove', 'del', 'rm'
        ExtraColorRole.where(role_id: role_id).delete_all

        embed event, "Removed `#{role_id}` from the list of extra color roles, if it was present."
      end

    when 'snippet', 's'
      subcmd = args.shift

      case subcmd
      when 'help', ''
        Config.help_msg event, 'cfg snippet', {
          list: 'list snippets',
          add: 'add a snippet to be recalled later',
          remove: 'remove a snippet from the list',
          set: 'set snippet attributes'
        }

      when 'list', 'l'
        QBot.bot.execute_command(:listsnippets, event, [])

      when 'add', 'a'
        name = args.shift
        text = args.join(' ').gsub('\n', "\n")

        if Snippet.find_by(server_id: event.server.id, name: name)
          embed event, "Snippet `#{name}` already exists."
          return
        end

        Snippet.create(server_id: event.server.id,
                       name: name,
                       text: text,
                       embed: true)

        embed event, "Created snippet `#{name}`."

      when 'edit', 'set', 'e', 's'
        name = args.shift
        text = args.join(' ').gsub('\n', "\n")

        if snippet = Snippet.find_by(server_id: event.server.id, name: name)
          snippet.text = text
          snippet.save!

          embed event, "Snippet `#{name}` edited successfully."
        else
          embed event, "Snippet `#{name}` not found."
          return
        end

      when 'remove', 'rm', 'delete', 'd'
        name = args.shift
        Snippet.where(server_id: event.server.id, name: name).delete_all
        embed event, "Removed snippet `#{name}`, if it was present."

      when 'prop', 'p'
        name = args.shift

        if name == 'help'
          Config.help_msg event, 'cfg snippet <name>', {
            embed: '(bool) is snippet a text message or an embed?'
          }
          return
        end

        snippet = Snippet.find_by(server_id: event.server.id, name: name)
        if !snippet
          embed event, "Snippet `#{name}` not found."
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

        embed event, "Property `#{subcmd}` of snippet `#{name}` is now `#{prop}`."

      end

    else
      embed event, 'Not yet implemented.'
      
    end
  end
  # rubocop: enable Metrics/BlockLength
end
