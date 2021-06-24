# frozen_string_literal: true

# Config helpers
module Config
  def self.help_msg(command, avail)
    cmd = prefixed command
    subcmds = subcommands(command, avail)

    embed <<~TEXT
      ```
      #{t 'cfg.usage'} #{cmd} <#{t 'cfg.subcmd'}> [#{t 'cfg.options'}]

      #{t 'cfg.avail_subcmd'}
      #{subcmds}
      ```
    TEXT
  end

  def self.subcommands(command, avail)
    tid_pfx = command.split.join('.') # translation ID prefix
    descriptions = avail.map { |name| t "#{tid_pfx}.help.#{name}" }

    avail.zip(descriptions).map { |cmd, desc| "    #{cmd} - #{desc}" }.join("\n")
  end

  def self.save_prefix(cfg, new_prefix)
    cfg.prefix = new_prefix
    cfg.save!

    embed t('cfg.prefix.saved', new_prefix)
  end
end
