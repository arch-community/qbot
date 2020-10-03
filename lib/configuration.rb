# frozen_string_literal: true

# Config helpers
module Config
  def self.[](server_id)
    ServerConfig[server_id]
  end

  def self.help_msg(event, command, avail)
    cmd = Config[event.server.id].prefix + command
    subcommands = avail.map { |k, v| "   #{k} - #{v}" }.join("\n")
    embed event, <<~TEXT
      ```
      Usage: #{cmd} <subcommand> [options]

      Available subcommands:
      #{subcommands}
      ```
    TEXT
  end

  def self.save_prefix(event, cfg, new_prefix)
    cfg.prefix = new_prefix
    cfg.save!
    ServerConfig.drop_from_cache(event.server.id)

    embed event, "New prefix `#{np}` saved."
  end
end
