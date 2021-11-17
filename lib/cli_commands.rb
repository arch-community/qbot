# frozen_string_literal: true

# Stop the bot
QBot.cli_command :stop, aliases: [:quit] do
  stop
  exit
end

# Reload the global bot config
QBot.cli_command 'reload-config', aliases: [:rc] do
  load_config
end

QBot.cli_command 'load-module', aliases: [:lm] do |name|
  load_module name
rescue LoadError
  puts "Module not found: #{name}"
end

QBot.cli_command 'restart', aliases: [:rs] do
  stop
  exec Gem.ruby, $PROGRAM_NAME
end

QBot.cli_command :irb do
  binding.irb # rubocop: disable Lint/Debugger
ensure
  Reline.prompt_proc = nil
end

QBot.cli_command :help do
  cmd_names = self.class.cli_commands.keys.map do |cmd|
    aliases = self.class.cli_aliases[cmd].map(&:first)

    if aliases.empty?
      cmd.to_s
    else
      "#{cmd} (#{aliases.join(', ')})"
    end
  end

  puts "Commands: #{cmd_names.join ', '}"
end
