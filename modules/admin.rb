# frozen_string_literal: true

require_relative 'admin/config_ui'

ServerConfig.extend_schema do
  column_option :prefix,
                TString.new(min_size: 1, max_size: 32),
                default: QBot.config.default_prefix

  column_option :log_channel_id, TSnowflake.new(format: :channel) do
    on_save do |_, value, event, *|
      new_channel = event.bot.channel(value)

      foreign = new_channel.server != event.server
      raise ArgumentError, t('cfg.log-channel.set.other-server') if foreign

    rescue Discordrb::Errors::UnknownChannel
      # UnknownChannel raised for invalid channel IDs
      embed t('cfg.log-channel.set.invalid-id', new_id)
      raise
    rescue Discordrb::Errors::NoPermission
      # NoPermission raised for channels qbot can't see
      embed t('cfg.log-channel.set.other-server', new_id)
      raise
    end
  end
end

# Administration commands
module Admin
  extend Discordrb::Commands::CommandContainer

  # rubocop: disable Lint/UselessAssignment, Security/Eval
  command :eval, {
    help_available: false,
    usage: '.eval <code>',
    min_args: 1
  } do |e, *_|
    m = e.message
    a = e.author

    next embed t('admin.eval.nope') unless a.id == QBot.config.owner

    code = after_nth_word(1, e.text)
    eval code
  end
  # rubocop: enable Lint/UselessAssignment, Security/Eval

  command :config, {
    aliases: [:cfg],
    help_available: true,
    usage: '.cfg <args>',
    min_args: 0
  } do |event, *args|
    next embed t('no_dm') if event.channel.pm?

    can_config =
      event.author.permission?(:manage_server) \
      || event.author.id == QBot.config.owner

    next embed t('no_perms') unless can_config

    schema = ServerConfig.schema
    cfg = ServerConfig.for(event.server)

    ConfigUI.config_command(schema, cfg, *args)
  end

  command :userconfig, {
    aliases: %i[ucfg uc],
    help_available: true,
    usage: '.uc <args>',
    min_args: 0
  } do |event, *args|
    schema = UserConfig.schema
    cfg = UserConfig.for(event.user)

    ConfigUI.config_command(schema, cfg, *args)
  end
end
