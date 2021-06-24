# frozen_string_literal: true

##
# Interface for registering commands for the QBot CLI
module CLIRegistry
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        attr_reader :cli_commands
      end
    end
  end

  def run_cli
    while (buf = Reline.readline('% ', true))
      cmd, *args = buf.chomp.split

      found = self.class.cli_commands.select { _1.start_with? cmd }

      puts 'Command ambiguous.' && return if found.size > 1
      puts 'Command not found' && return if found.empty?

      proc = found.values.first

      instance_exec(*args, &proc)
    end
  end

  module ClassMethods
    def cli_command(name, aliases: [], &block)
      @cli_commands ||= {}
      @cli_commands[name] = block
      aliases.each { @cli_commands[_1] = block }
    end
  end
end
