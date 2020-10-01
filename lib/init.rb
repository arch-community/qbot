def print_logo(version)
  logo = File.read './lib/logo.txt'

  puts "\n#{logo.chomp}  version #{version}\n\n"
end

def init_config
  $config = (YAML.load_file 'config.yml' || {}).to_hashugar
end

def load_config
  init_config
  Log4r::Logger['bot'].info 'Loaded configuration'
end

def init_log
  $applog = Log4r::Logger.new 'bot'
  $applog.outputters = Log4r::Outputter.stderr
end

def init_bot
  token     = $config.token     || raise('No token in configuration; set token')
  client_id = $config.client_id || raise('No client_id in configuration; set client_id')

  $bot = Discordrb::Commands::CommandBot.new(
    token: token,
    client_id: client_id,
    name: 'QueryBot',
    prefix: method(:cmd_prefix),
    fancy_log: true,
    ignore_bots: true,
    no_permission_message: 'You are not allowed to do that',
    help_command: false,
    intents: Discordrb::INTENTS.keys - [
      :server_presences,
      :server_message_typing,
      :direct_message_typing
    ]
  )
end
