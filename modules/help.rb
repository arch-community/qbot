# frozen_string_literal: true

# Modified from discordrb source. This file is available under the MIT license.

# Help command
module Help
  extend Discordrb::Commands::CommandContainer

  # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def self.cmd_help(event, name)
    command = event.bot.commands[name.to_sym]
    if command.is_a?(Discordrb::Commands::CommandAlias)
      command = command.aliased_command
      name = command.name
    end

    if !command || !can_run?(command.name, event)
      embed t('help.not-found', name)
      return
    end

    fields = []

    aliases = event.bot.command_aliases(name.to_sym)
    unless aliases.empty?
      fields << {
        name: t('help.aliases'),
        value: aliases.map { |a| "`#{a.name}`" }.join(', '),
        inline: true
      }
    end

    if (usage = command.attributes[:usage])
      fields << {
        name: t('help.usage'),
        value: "`#{usage}`",
        inline: true
      }
    end

    if (parameters = command.attributes[:parameters])
      fields << {
        name: t('help.valid-params'),
        value: "```\n#{parameters.join "\n"}\n```"
      }
    end

    desc = t "descriptions.#{command.name}"

    embed do |m|
      m.title = prefixed name
      m.description = desc if desc
      m.fields = fields unless fields.empty?
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/MethodLength, Metrics/PerceivedComplexity

  def self.available_commands(event)
    event.bot.commands.values.reject do |c|
      c.is_a?(Discordrb::Commands::CommandAlias) ||
        !c.attributes[:help_available] ||
        !event.bot.send(:required_roles?, event.user, c.attributes[:required_roles]) ||
        !event.bot.send(:allowed_roles?, event.user, c.attributes[:allowed_roles]) ||
        !event.bot.send(:required_permissions?, event.user, c.attributes[:required_permissions], event.channel) ||
        !can_run?(c.name, event)
    end
  end
  # rubocop: enable Metrics/AbcSize

  def self.embed_full(_event, avail)
    embed do |m|
      m.title = t 'help.list-title'
      m.fields = avail.map {
        desc = t("descriptions.#{_1.name}") || ''
        {
          name: prefixed(_1.name),
          value: desc
        }
      }
    end
  end

  def self.embed_compact(_event, avail)
    embed do |m|
      m.title = t 'help.list-title'
      m.description = avail.map { "`#{prefixed _1.name}`" }.join(', ')
    end
  end

  def self.all_help(event)
    avail = available_commands(event)
    case avail.length
    when 0..25
      embed_full(event, avail)
    else
      embed_compact(event, avail)
    end
  end

  command :help, {
    aliases: [:h],
    help_available: true,
    usage: '.help [command]',
    min_args: 0,
    max_args: 1
  } do |event, command_name|
    if command_name
      Help.cmd_help(event, command_name)
    else
      Help.all_help(event)
    end
  end
end
