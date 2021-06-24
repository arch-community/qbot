# frozen_string_literal: true

##
# QBot's command line interface
module CLIRegistry
  def cli_command(name, aliases: [], &block)
    @cli_commands ||= {}
    @cli_commands[name] = block
    aliases.each { @cli_commands[_1] = block }
  end

  def run_cli
    while (buf = Reline.readline('% ', true))
      cmd, *args = buf.chomp.split

      found = cli_commands.select { _1.start_with? cmd }

      if found.size > 1
        puts 'Command ambiguous.'
      elsif found.empty?
        puts 'Command not found'
      else
        instance_eval(block, *args)
      end
    end
  end

  # Stop the bot
  cli_command :stop, aliases: [:quit] do
    stop
    exit
  end

  # Reload the global bot config
  cli_command 'reload-config', aliases: [:rc] do
    load_config
  end

  cli_command 'load-module', aliases: [:lm] do |name|
    load_module name
  rescue LoadError
    puts "Module not found: #{name}"
  end

  cli_command 'restart', aliases: [:rs] do
    stop
    exec Gem.ruby, $PROGRAM_NAME
  end

  cli_command :irb do
    binding.irb # rubocop: disable Lint/Debugger
  end
end
