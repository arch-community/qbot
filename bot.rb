#!/usr/bin/env ruby

Bundler.require :default
require 'yaml'
require 'open-uri'

require './lib/patches'
require './lib/helpers'

$applog = Log4r::Logger.new 'bot'
$applog.outputters = Log4r::Outputter.stderr

load_config

token = $config.token || raise('No token in configuration; set token')
client_id = $config.client_id || raise('No client_id in configuration; set client_id')

$applog.debug 'Init bot object'
$bot = Discordrb::Commands::CommandBot.new(
  token: token,
  client_id: client_id,
  name: 'QueryBot',
  prefix: method(:cmd_prefix),
  fancy_log: true,
  ignore_bots: true,
  no_permission_message: 'You are not allowed to do that',
  help_command: false,
)


$applog.debug 'Init DB'
require_relative 'lib/db'

$config.global.modules.each do
  require_relative "modules/#{_1}"
  eval "$bot.include! #{_1.capitalize}"
  $applog.info "Loaded module: #{_1}"
end

$applog.info 'Initializing connection'
$bot.run :async
$applog.info 'Startup complete'

while buf = Readline.readline('% ', true)
  s = buf.chomp

  if s.start_with? 'quit', 'stop'
    $bot.stop
    exit

  elsif s.start_with? 'reload'
    load_config

  elsif s.start_with? 'rs', 'restart'
    $bot.stop
    exec 'ruby', $PROGRAM_NAME

  elsif s.start_with? 'irb'
    binding.irb

  elsif s == ''
    next

  else
    puts 'Command not found'

  end
end

$bot.sync
