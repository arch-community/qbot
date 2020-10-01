#!/usr/bin/env ruby

$VERSION = '0.1a'

Bundler.require :default
require 'json'
require 'yaml'
require 'digest'
require 'uri'
require 'open-uri'

require_relative 'lib/options'
require_relative 'lib/patches'
require_relative 'lib/helpers'
require_relative 'lib/breaking_wrap'
require_relative 'lib/modules'
require_relative 'lib/cli'
require_relative 'lib/init'

$options = QBot.parse_options(ARGV)

print_logo $VERSION

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

trap :INT do
  Thread.new { $applog.fatal 'Ctrl-C caught, exiting gracefully...' }.join
  $bot.stop
  exit 130
end

QBot.run_cli

$bot.sync
