# frozen_string_literal: true

# Initialization code for the bot
module QBot
  def self.print_logo(version)
    logo = File.read File.join(__dir__, 'resources/logo.txt')
    puts "\n#{logo.chomp}   #{Paint["version #{version}", :italic, :bright, :gray]}\n\n"
  end

  def self.init_config = (YAML.unsafe_load_file @options.config_path || {}).to_hashugar

  def self.load_config
    @config = init_config
    Log4r::Logger['bot'].info 'Loaded configuration'
  end

  def self.init_log
    logger = Log4r::Logger.new 'bot'
    # logger.outputters = Log4r::Outputter.stderr

    Log4r::ColorOutputter.new 'color', {
      colors: {
        debug: :white,
        info: :green,
        warn: :yellow, error: :red, fatal: :red
      }
    }
    logger.add 'color'

    logger
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def self.init_bot
    token     = @config.token     || raise('No token in configuration; set token')
    client_id = @config.client_id || raise('No client_id in configuration; set client_id')

    Discordrb::Commands::CommandBot.new(
      token:,
      client_id:,
      name: 'QueryBot',
      prefix: method(:cmd_prefix),
      fancy_log: true,
      ignore_bots: true,
      no_permission_message: 'You are not allowed to do that',
      help_command: false,
      intents: Discordrb::INTENTS.keys - %i[
        server_presences
        server_message_typing
        direct_message_typing
      ]
    )
  end

  def self.run!
    @options = parse_options(ARGV)

    print_logo @version

    @config = init_config
    @log = init_log

    @log.debug 'Init bot object'
    @bot = init_bot

    @log.debug 'Init DB'
    Database.init_db

    @log.debug 'Init modules'
    Modules.load_all

    @log.info 'Initializing connection...'

    @bot.ready do |event|
      @log.info 'Bot ready.'
      event.bot.playing = "version #{version}"
    end

    @bot.run :async

    trap :INT do
      Thread.new { QBot.log.fatal 'Ctrl-C caught, exiting gracefully...' }.join
      QBot.bot.stop
      exit 130
    end

    run_cli unless QBot.options.no_console

    @bot.sync
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end
