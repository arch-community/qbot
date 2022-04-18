# frozen_string_literal: true

# Config helpers
module Admin
  def self.to_path(stack)
    stack.map(&:name).join('/')
  end

  def self.parse_value(option, args)
    case option.type
    when :string
      args.join(' ')
    when :integer
      parse_int(args.join(' '))
    when :bool
      parse_bool(args.first)
    when :snowflake
      parse_int(args.first)
    end
  end

  def self.group_help(opts: nil, schema: ServerConfig.option_schema)
    opts ||= schema

    embed do |m|
      m.title = 'Available options'
      m.description =
        opts.map { "**`#{_1.name}`** _(#{_1.type})_" }
            .join("\n")
    end
  end

  def self.simple_opt_help(event, option)
    out = String.new
    out << "Option: **`#{option.name}`** _(#{option.type})_\n"

    cur_val = ServerConfig[event.server.id].get(option) || 'unset'

    out << "Current value: `#{cur_val}`.\n\n"
    out << "Append a #{option.type} to this command to set the option.\n"
    out << "Append `reset` to set **`#{option.name}`** to its default value"
    out << " (`#{option.default}`)" if option.default
    out << '.'
    embed out
  end

  def self.opt_confirm(option, val)
    embed do |m|
      m.title = 'Option changed'
      m.description = "The value of **`#{option.path}`** is now `#{val}`."
    end
  end

  def self.opt_invalid(option, val)
    embed do |m|
      m.title = 'Invalid value'
      m.description = "The value `#{val}` is not valid for **`#{option.path}`**."
    end
  end
end
