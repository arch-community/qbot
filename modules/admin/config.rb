# frozen_string_literal: true

# Configuration command for the admin module.
module Admin
  extend Discordrb::Commands::CommandContainer

  def self.handle_opt(event, opt, args)
    case opt.type
    when :string, :integer, :bool, :snowflake
      simple_opt(event, opt, args)
    when :selection
      selection_opt(event, opt, args)
    when :collection
      collection_opt(event, opt, args)
    when :command
      embed opt.attrs[event, *args]
    end
  end

  def self.simple_opt(event, option, args)
    op, = args
    case op
    when nil, 'help'
      simple_opt_help(event, option)
    when 'reset'
      ServerConfig[event.server.id].set(option, option.default)
      opt_confirm(option, 'unset')
    else
      if (val = parse_value(option, args))
        ServerConfig[event.server.id].set(option, val)
        opt_confirm(option, val)
      else
        opt_invalid(option, args.join(' '))
      end
    end
  end

  def self.selection_opt(event, option, args)
    pp option
    embed do |m|
      m.title = "`#{option.path}`"
      m.description = option.attrs.values[].to_s
    end
  end

  def self.collection_opt(event, option, args)
    event.respond("#{option}\n#{args}")
  end

  command :config, {
    aliases: [:cfg],
    help_available: true,
    usage: '.cfg <args>',
    min_args: 0
  } do |event, *args|
    if event.channel.pm?
      embed t('no_dm')
      return
    end

    unless event.author.permission?(:administrator) || event.author.id == QBot.config.owner
      embed t('no_perms')
      return
    end

    opts = ServerConfig.option_schema
    stack = []

    loop do
      cmd = args.shift
      p cmd
      if !cmd || cmd.start_with?('help')
        group_help opts: stack.last&.attrs
        break
      elsif (opt = ServerConfig.find_opt(cmd, opts:))
        p opt
        if opt.type == :group
          stack << opt
          opts = opt.attrs
        else
          handle_opt(event, opt, args)
          break
        end
      else
        event.respond "#{to_path stack}: #{cmd} not found."
        break
      end
    end
  end
end
