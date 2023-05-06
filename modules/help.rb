# frozen_string_literal: true

# Help command
module Help
  extend Discordrb::Commands::CommandContainer

  def self.find_command(query)
    command = QBot.bot.commands[query.to_sym]

    is_alias = command.is_a?(Discordrb::Commands::CommandAlias)
    return command.aliased_command if is_alias

    command
  end

  def self.usage_fields(cmd)
    usage = cmd.attributes[:usage]
    return [] unless usage

    value = "`#{usage}`"

    [{ name: t('help.usage'), value: }]
  end

  def self.aliases_fields(cmd)
    aliases = QBot.bot.command_aliases(cmd.name)
    return [] if aliases.empty?

    value = aliases.map { "`#{prefixed(_1.name)}`" }.join("\n")

    [{ name: t('help.aliases'), value:, inline: true }]
  end

  def self.param_fields(cmd)
    params = cmd.attributes[:parameters]
    return [] unless params

    value = parameters.map { "`#{_1}`" }.join(', ')

    [{ name: t('help.valid-params'), value:, inline: true }]
  end

  def self.show_cmd_help(query)
    cmd = find_command(query)

    return embed t('help.not-found', query) unless cmd

    embed do |m|
      m.title = prefixed(cmd.name)
      m.description = t("descriptions.#{cmd.name}")

      m.fields = usage_fields(cmd) + aliases_fields(cmd) + param_fields(cmd)
    end
  end

  def self.visible?(cmd)
    return false if cmd.is_a?(Discordrb::Commands::CommandAlias)

    cmd.attributes[:help_available]
  end

  def self.available_commands
    all_cmds = QBot.bot.commands.values

    all_cmds.filter { visible?(_1) }
  end

  def self.command_field(cmd)
    {
      name: prefixed(cmd.name),
      value: t("descriptions.#{cmd.name}")
    }
  end

  def self.embed_full
    embed do |m|
      m.title = t('help.list-title')
      m.fields = available_commands.map { command_field(_1) }
    end
  end

  def self.embed_compact
    embed do |m|
      m.title = t('help.list-title')

      m.description = \
        available_commands
        .map { |cmd| prefixed(cmd.name) }
        .then { |names| <<~DESC }
          ```
          #{names.join("\n")}
          ```
        DESC
    end
  end

  def self.show_all_help
    case available_commands.length
    when 0..25
      embed_full
    else
      embed_compact
    end
  end

  command :help, {
    aliases: [:h],
    help_available: true,
    usage: '.help [command]',
    min_args: 0,
    max_args: 1
  } do |_, name|
    if name
      show_cmd_help(name)
    else
      show_all_help
    end
  end
end
