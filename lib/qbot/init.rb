# frozen_string_literal: true

require 'active_support/ordered_options'

def find_prefix(message)
  if message.channel.pm?
    QBot.config.default_prefix
  else
    ServerConfig.for(message.server.id).server_prefix
  end
end

def cmd_prefix(message)
  pfx = find_prefix(message)

  if message.text.start_with?("#{pfx} ")
    message.text[(pfx.length + 1)..]
  elsif message.text.start_with?(pfx)
    message.text[pfx.length..]
  end
end

# Initialization code for the bot
module QBot
  class << self
    attr_accessor :worker, :worker_thread, :scheduler
  end

  @scheduler = nil

  def self.init_log
    @log = Discordrb::Logger.new(true)
  end

  def self.print_logo(version)
    logo = File.read File.join(__dir__, *%w[.. .. share logo.txt])
    puts "\n#{logo.chomp}   #{Paint["version #{version}", :italic, :bright, :gray]}\n\n"

    @log.info "starting up qbot, version #{version}"
  end

  def self.to_inheritable_options(hash)
    hash
      .transform_values { _1.is_a?(Hash) ? to_inheritable_options(_1) : _1 }
      .then { ActiveSupport::InheritableOptions.new(_1) }
  end

  def self.load_config
    yaml = YAML.load_file(
      @options.config_path,
      aliases: true,
      symbolize_names: true
    )

    raise 'Invalid config path' unless yaml

    to_inheritable_options(yaml)
  end

  def self.init_config
    @config = load_config
    @log.info 'Loaded configuration'
  end

  def self.init_delayed_jobs
    @worker = Delayed::Worker.new(
      exit_on_complete: false
    )

    @worker_thread = Thread.new do
      @worker.start
    end
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def self.init_bot
    @log.debug 'Init bot object'

    token     = @config.token     || raise('No token in configuration; set token')
    client_id = @config.client_id || raise('No client_id in configuration; set client_id')

    @bot = Discordrb::Commands::CommandBot.new(
      token:, client_id:, name: 'qbot',
      prefix: method(:cmd_prefix),
      fancy_log: true,
      ignore_bots: false,
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

    init_log
    print_logo @version

    init_config

    init_bot

    @log.debug 'Init DB'
    Database.init_db

    init_delayed_jobs
    @scheduler = Rufus::Scheduler.new

    @log.debug 'Init modules'
    Modules.load_all

    @log.info 'Initializing connection...'

    @bot.ready do |event|
      @log.info 'Bot ready.'
      event.bot.playing = "version #{version}"
    end

    @bot.run :async

    trap :INT do
      Thread.new { QBot.log.info 'Ctrl-C caught, exiting gracefully...' }.join
      @worker.stop
      QBot.bot.stop
      exit 130
    end

    run_cli unless QBot.options.no_console

    @bot.sync
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
  
  def self.stop
    @worker.stop
    @scheduler.shutdown(:wait)
    @bot.stop
  end
end
