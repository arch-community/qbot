# frozen_string_literal: true

require 'abbrev'

##
# Implements a user interface for configuration.
#
# A command such as `.cfg sitelenpona fontsize set 40` names a path into
# the schema, followed by a verb and its arguments. The path resolves to
# either a Group of options or a single Setting. Both know how to describe
# themselves; a Setting also knows how to change its value.
module ConfigUI
  ##
  # Every reply from the config UI has the same shape: a title, a few
  # fields and a footer carrying the bot's icon.
  def self.reply(title, fields: [], description: nil, footer: 'type:cfg')
    embed do |m|
      m.title = title
      m.description = description
      m.fields = fields

      icon_url = QBot.bot.profile.avatar_url
      m.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer, icon_url:)
    end
  end

  ##
  # A group of options, found at `path` in the schema of `cfg`'s class.
  class Group < Data.define(:entries, :path, :cfg)
    # Follows the arguments down the schema for as long as they name
    # groups and options, returning the node reached and the leftover
    # arguments.
    def resolve(name = nil, *rest)
      child(name)&.resolve(*rest) || [self, []]
    end

    def run(*) = help

    # Same format as Configurable::Option#ui_path
    def ui_path = path.map(&:inspect).join

    def summary_line = t('cfg.help.schema.group', path.last)

    def help
      ConfigUI.reply(
        title,
        description: children.map(&:summary_line).join("\n"),
        footer: t('cfg.help.schema.footer')
      )
    end

    def title
      return t('cfg.help.schema.title-root') if path.empty?

      t('cfg.help.schema.title', ui_path)
    end

    def children = entries.keys.map { node(_1) }

    def child(name)
      key = entries.keys.abbrev[name&.strip&.downcase]
      node(key) if key
    end

    private def node(key)
      value = entries[key]
      child_path = [*path, key]

      if value.is_a?(Hash)
        Group.new(value, child_path, cfg)
      else
        Setting.new(value, cfg)
      end
    end
  end

  ##
  # A single option, bound to the record whose value it reads and writes.
  class Setting < Data.define(:option, :cfg)
    VERBS = %w[set clear reset].freeze

    def resolve(*args) = [self, args]

    def run(verb = nil, *args)
      case VERBS.abbrev[verb&.strip&.downcase]
      when 'set' then set(args.join(' '))
      when 'clear', 'reset' then clear
      else help
      end
    end

    def summary_line
      t('cfg.help.schema.option', option.name, option.type.short_name)
    end

    def help
      ConfigUI.reply(
        t('cfg.help.option.title', option.localized_name, option.ui_path),
        description: option.description,
        fields: help_fields,
        footer: t('cfg.help.option.footer')
      )
    end

    def help_fields
      type = option.type

      [
        { name: t('cfg.help.option.type'), value: type.describe_self },
        { name: t('cfg.help.option.valid'), value: type.describe_validation },
        { name: t('cfg.help.option.current'), value: option.show_value(cfg),
          inline: true },
        { name: t('cfg.help.option.default'), value: option.show_default(cfg),
          inline: true }
      ]
    end

    def set(raw)
      value = option.set_for_record(cfg, option.type.read(raw))

      ConfigUI.reply(
        t('cfg.set.success.title', option.ui_path),
        fields: new_value_field(value)
      )
    rescue ArgumentError => e
      set_error(raw, e)
    end

    def set_error(raw, error)
      ConfigUI.reply(
        t('cfg.set.error.title', option.ui_path),
        fields: [
          { name: t('cfg.set.error.explanation'), value: error.to_s },
          { name: t('cfg.set.error.input'), value: raw.truncate(1024) }
        ]
      )
    end

    def clear
      option.set_for_record(cfg, nil)

      ConfigUI.reply(
        t('cfg.set.success.clear-title', option.ui_path),
        fields: new_value_field(option.get_for_record(cfg))
      )
    end

    def new_value_field(value)
      [{ name: t('cfg.set.success.new-value'), value: option.show(value) }]
    end
  end

  def self.config_command(schema, cfg, *)
    node, rest = Group.new(schema, [], cfg).resolve(*)

    node.run(*rest)
  end
end
