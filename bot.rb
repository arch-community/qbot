#!/usr/bin/env ruby

Bundler.require :default
require 'json'
require 'yaml'
require 'digest'
require 'uri'
require 'open-uri'

require_relative 'lib/patches'
require_relative 'lib/helpers'
require_relative 'lib/breaking_wrap'
require_relative 'lib/modules'
require_relative 'lib/cli'
require_relative 'lib/init'

print_logo "0.1a"

init_config
init_log

$applog.debug 'Init bot object'
init_bot

$applog.debug 'Init DB'
require_relative 'lib/db'

$applog.debug 'Init modules'
Modules.load_all

$applog.info 'Initializing connection...'

$bot.run :async
$bot.ready do
  $applog.info 'Bot ready.'
end

QBot::run_cli

$bot.sync
