# frozen_string_literal: true

# Configuration command for the admin module.
module Admin
  extend Discordrb::Commands::CommandContainer

  def self.help_cmd(stack)
    opts = ServerConfig.option_schema
    stack.each { |name| opts = opts.find { _1.name == name }.attrs }
    opts.map { "#{_1.name} (#{_1.type})" }
        .join("\n")
        .then { "```#{_1}```"}
  end

  def self.opt_help(event, option)
    out = String.new
    out << "Option: `#{option.name}` (#{option.type})\n"

    cur_val = case option.type
      when :string, :integer, :bool, :snowflake
        ServerConfig[event.server.id].get(option.path) || 'unset'
      when :selection
        # stub
      when :collection
        # stub
    end

    out << "Current value: `#{cur_val}`.\n\n"
    out << "Append a #{option.type} to this command to set the option.\n"
    out << "Append `reset` to set `#{option.name}` to its default value"
    out << " (`#{option.default}`)" if option.default
    out << '.'
    embed out
  end

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

  def self.parse_value(option, args)
    case option.type
    when :string
      args.join(' ')
    when :integer
      Integer(args.join(' '))
    when :bool
      args.first.downcase.start_with?('t', 'y')
    when :snowflake
      Integer(args.first)
    end
  end

  def self.simple_opt(event, option, args)
    op, = args
    case op
    when nil, 'help'
      opt_help(event, option)
    when 'reset'
      option.db_set(event, option.default)
    else
      val = parse_value(option, args)
      option.db_set(event, val)
    end
  end

  def self.selection_opt(event, option, args)
    event.respond("#{option}\n#{args}")
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
        event.respond help_cmd stack
        break
      elsif (opt = opts.find { _1.name.to_s == cmd })
        if opt.type == :group
          stack << opt.name
          opts = opt.attrs
        else
          handle_opt(event, opt, args)
          break
        end
      else
        event.respond "#{stack}: #{cmd} not found."
        break
      end
    end
  end
end
