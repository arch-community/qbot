# frozen_string_literal: true

##
# Interface for registering commands for the QBot CLI
module CLIRegistry
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        attr_reader :cli_commands, :cli_aliases
      end
    end
  end

  def find_cmds(name)
    self.class.cli_commands
        .merge(self.class.cli_aliases.values.flatten(1).to_h)
        .select { _1.start_with? name }
  end

  def run_cli
    while (buf = Reline.readline('[qbot]% ', true))
      name, *args = buf.strip.split
      next unless name

      matches = find_cmds(name)
      puts('Command not found.') || next if matches.empty?
      puts('Command ambiguous.') || next if matches.size > 1

      proc = matches.values.first
      instance_exec(*args, &proc)
    end
  end

  # Class methods
  module ClassMethods
    def cli_command(name, aliases: [], &block)
      @cli_commands ||= {}
      @cli_aliases ||= {}

      @cli_commands[name] = block
      @cli_aliases[name] = aliases.map { [_1, block] }
    end
  end
end
