# Modified from discordrb source. This file is available under the MIT license.

module Help
  extend Discordrb::Commands::CommandContainer

  command :help, {
    aliases: [ :h ],
    help_available: true,
    description: 'Shows a list of all available commands or displays help for a specific command',
    usage: '.help [command]',
    min_args: 0,
    max_args: 1
  } do |event, command_name|
    log(event)

    pfx = prefix(event.server.id)

    if command_name
      command = event.bot.commands[command_name.to_sym]
      if command.is_a?(Discordrb::Commands::CommandAlias)
        command = command.aliased_command
        command_name = command.name
      end

      unless command
        event.channel.send_embed { _1.description = "The command `#{command_name}` does not exist." }
        return
      end

      fields = []

      aliases = event.bot.command_aliases(command_name.to_sym)
      if not aliases.empty?
        fields << {
          name: 'Aliases',
          value: aliases.map { |a| "`#{a.name}`" }.join(', '),
          inline: true,
        }
      end

      usage = command.attributes[:usage]
      fields << { name: 'Usage', value: "`#{usage}`", inline: true } if usage

      parameters = command.attributes[:parameters]
      if parameters
        fields << {
          name: 'Accepted parameters',
          value: "```\n#{parameters.join ?\n}\n```"
        }
      end

      desc = command.attributes[:description]

      event.channel.send_embed do |m|
        m.title = "#{pfx}#{command_name}"
        m.description = desc if desc
        m.fields = fields unless fields.empty?
      end
    else
      available_commands = event.bot.commands.values.reject do |c|
        c.is_a?(Discordrb::Commands::CommandAlias) ||
          !c.attributes[:help_available] ||
          !event.bot.send(:required_roles?, event.user, c.attributes[:required_roles]) ||
          !event.bot.send(:allowed_roles?, event.user, c.attributes[:allowed_roles]) ||
          !event.bot.send(:required_permissions?, event.user, c.attributes[:required_permissions], event.channel)
      end

      case available_commands.length
      when 0..25
        event.channel.send_embed do |m|
          m.title = 'List of commands'
          m.fields = available_commands.map { {
            name: "#{pfx}#{_1.name}",
            value: _1.attributes[:description] || "",
          } }
        end
        return
      when 25..50
        (available_commands.reduce "**List of commands:**\n" do |memo, c|
          memo + "`#{c.name}`, "
        end)[0..-3]
      else
        event.user.pm(available_commands.reduce("**List of commands:**\n") { |m, e| m + "`#{e.name}`, " }[0..-3])
        event.channel.pm? ? '' : 'Sending list in PM!'
      end
    end
  end
end
