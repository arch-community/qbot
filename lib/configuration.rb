# frozen_string_literal: true

# Config helpers
module Config
  def self.[](server_id)
    ServerConfig[server_id]
  end

  def self.help_msg(e, command, avail)
    cmd = Config[e.server.id].prefix + command
    tid_pfx = command.split.join('.')
    descriptions = avail.map { |name| t "#{tid_pfx}.help.#{name}" }
    subcommands = avail.zip(descriptions).map { |cmd, desc|
      "    #{cmd} - #{desc}"
    }.join(?\n)

    embed e, <<~TEXT
      ```
      #{t 'cfg.usage'} #{cmd} <#{t 'cfg.subcmd'}> [#{t 'cfg.options'}]

      #{t 'cfg.avail_subcmd'}
      #{subcommands}
      ```
    TEXT
  end

  def self.save_prefix(event, cfg, new_prefix)
    cfg.prefix = new_prefix
    cfg.save!

    embed event, t('cfg.prefix.saved', new_prefix)
  end
end
