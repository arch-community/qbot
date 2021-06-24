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
end
