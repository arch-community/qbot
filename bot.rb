#!/usr/bin/env ruby

Bundler.require :default
require './lib/patches'
require 'yaml'
require 'open-uri'

$applog = Log4r::Logger.new 'bot'
$applog.outputters = Log4r::Outputter.stderr

$config = YAML.load_file 'config.yml' || {}

token = $config['token']
raise 'No token in configuration; set token' unless token

client_id = $config['client_id']
raise 'No client_id in configuration; set client_id' unless client_id


$bot = Discordrb::Commands::CommandBot.new(
  token: token,
  client_id: client_id,
  name: 'QueryBot',

  prefix: -> (m) {
    pfx = $config['servers'][m.channel.server.id]['prefix'] || '.'
    m.text.start_with?(pfx) ? m.text[pfx.length..-1] : nil
  },

  fancy_log: true,
  ignore_bots: true,

  no_permission_message: 'You are not allowed to do that',
)


modules = $config['modules']

require_relative 'lib/db'

modules.each do
  require_relative "modules/#{_1}"
  eval "$bot.include! #{_1.capitalize}"
end

$bot.run :async

while buf = Readline.readline('% ', true)
  s = buf.chomp
  if s.start_with? 'quit', 'stop'
    $bot.stop
    exit
  elsif s.start_with? 'reload'
    $config = YAML.load_file 'config.yml' || {}
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
