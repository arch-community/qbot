module Config
  def self.[](server_id)
    ServerConfig[server_id]
  end

  def self.help_msg(event, command, avail)
    cmd = prefix(event.server.id) + command
    subcommands = avail.map { |k, v| "   #{k} - #{v}" }.join("\n")
    embed event, <<~END
      ```
      Usage: #{cmd} <subcommand> [options]

      Available subcommands:
      #{subcommands}
      ```
    END
  end

  def self.save_prefix(event, cfg, np)
    cfg.prefix = np
    @prefixes[event.server.id] = np
    cfg.save!

    embed event, "New prefix `#{np}` saved."
  end
end
