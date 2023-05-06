# frozen_string_literal: true

require 'abbrev'

##
# Implements a user interface for configuration
module ConfigUI
  FoundOption = Data.define(:target, :path, :args)

  def self.get_option(root, name = nil, *rest, path: [])
    abbrevs = root.keys.abbrev
    target_key = abbrevs[name&.strip&.downcase]
    target = root[target_key]

    if target.is_a? Hash
      get_option(target, *rest, path: path << name)
    elsif target.nil?
      FoundOption[target: root, path:, args: nil]
    else
      FoundOption[target:, path:, args: rest]
    end
  end

  def self.cfg_footer(text = 'type:cfg')
    Discordrb::Webhooks::EmbedFooter.new(
      text:,
      icon_url: QBot.bot.profile.avatar_url
    )
  end

  def self.schema_help_line(name, option)
    if option.is_a?(Hash)
      t('cfg.help.schema.group', name)
    else
      t('cfg.help.schema.option', name, option.type.short_name)
    end
  end

  def self.schema_description(schema)
    schema.map { |name, option| schema_help_line(name, option) }.join("\n")
  end

  def self.schema_help(schema, path)
    display_path = path.join(':').prepend(':')

    embed do |m|
      m.title = t('cfg.help.schema.title', display_path) unless path.empty?
      m.title = t('cfg.help.schema.title-root') if path.empty?

      m.description = schema_description(schema)
      m.footer = cfg_footer t('cfg.help.schema.footer')
    end
  end

  def self.option_fields(cfg, option)
    val = option.show_value(cfg)
    default = option.show_default(cfg)
    type = option.type.describe_self
    valid = option.type.describe_validation

    [
      { name: t('cfg.help.option.type'), value: type },
      { name: t('cfg.help.option.valid'), value: valid },
      { name: t('cfg.help.option.current'), value: val, inline: true },
      { name: t('cfg.help.option.default'), value: default, inline: true }
    ]
  end

  def self.option_help(cfg, option)
    embed do |m|
      m.title = t('cfg.help.option.title', option.localized_name, option.ui_path)
      m.description = option.description

      m.fields = option_fields(cfg, option)

      m.footer = cfg_footer t('cfg.help.option.footer')
    end
  end

  def self.option_set_error_embed(option, new_val, error)
    embed do |m|
      m.title = t('cfg.set.error.title', option.ui_path)

      m.fields = [
        { name: t('cfg.set.error.explanation'), value: error.to_s },
        { name: t('cfg.set.error.input'), value: new_val.to_s.truncate(1024) }
      ]

      m.footer = cfg_footer
    end
  end

  def self.option_set_success_embed(option, val, clear: false)
    val_text = option.show(val)

    embed do |m|
      m.title = t('cfg.set.success.title', option.ui_path) unless clear
      m.title = t('cfg.set.success.clear-title', option.ui_path) if clear

      m.fields = [
        { name: t('cfg.set.success.new-value'), value: val_text }
      ]

      m.footer = cfg_footer
    end
  end

  def self.option_set(cfg, option, *args)
    new_val = option.type.read(args.join(' '))
    res = option.set_for_record(cfg, new_val)

    option_set_success_embed(option, res)
  rescue ArgumentError => e
    option_set_error_embed(option, args.join(' '), e)
  end

  def self.option_clear(cfg, option, *)
    option.set_for_record(cfg, nil)
    val = option.get_for_record(cfg)

    option_set_success_embed(option, val, clear: true)
  end

  def self.option_op(cfg, option, cmd, *args)
    verbs = %w[set clear reset]
    verb = verbs.abbrev[cmd]

    case verb
    when 'set'
      option_set(cfg, option, *args)
    when 'clear', 'reset'
      option_clear(cfg, option)
    else
      option_help(cfg, option)
    end
  end

  def self.config_command(schema, cfg, *args)
    get_option(schema, *args) => target, path, args

    return schema_help(target, path) if target.is_a?(Hash)

    cmd = args.shift&.then { _1.strip.downcase }
    option_op(cfg, target, cmd, *args)
  end
end
