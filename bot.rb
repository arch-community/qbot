#!/usr/bin/env ruby

Bundler.require :default
require 'json'
require 'yaml'
require 'digest'
require 'uri'
require 'open-uri'

require './lib/patches'
require './lib/helpers'
require './lib/breaking_wrap'
require './lib/cli'


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
  intents: Discordrb::INTENTS.keys - [
    :server_presences,
    :server_message_typing,
    :direct_message_typing
  ]
)


$applog.debug 'Init DB'
require_relative 'lib/db'

$config.global.modules.each do
  require_relative "modules/#{_1}"
  eval "$bot.include! #{_1.capitalize}"
  $applog.info "Loaded module: #{_1}"
end

$applog.info 'Initializing connection'

$bot.ready do
  $applog.info 'Startup complete'
end

$bot.run :async

QBot::run_cli

$bot.sync
