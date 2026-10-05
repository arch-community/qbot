#!/usr/bin/env ruby
# frozen_string_literal: true

# Boots the bot short of connecting to the gateway and loads every module.

require 'tmpdir'
require_relative '../lib/qbot'

MODULES = Dir[File.join(__dir__, '..', 'modules', '*.rb')].map { |path|
  File.basename(path, '.rb')
}.sort

ARCH = {
  'mirror' => 'https://mirrors.edge.kernel.org/archlinux/',
  'repos' => %w[core extra multilib]
}.freeze

def write_config(dir)
  config = {
    'token' => 'x', 'client_id' => 1, 'owner' => 1, 'arch' => ARCH,
    'database' => { 'type' => 'sqlite3', 'db' => 'db.sqlite3' },
    'my_repo' => 'https://github.com/arch-community/qbot',
    'default_prefix' => '.',
    'modules' => MODULES
  }

  File.join(dir, 'global.yml').tap { File.write(_1, config.to_yaml) }
end

def boot(dir)
  QBot.options = QBot.parse_options(['-c', write_config(dir), '-s', dir])
  QBot.init_log
  QBot.init_config
  QBot.init_bot
  QBot::Database.init_db
  QBot::Database.define_schema
  QBot.scheduler = Rufus::Scheduler.new
end

Dir.mktmpdir('qbot-smoke') do |dir|
  boot(dir)
  Modules.load_all

  MODULES.each do |name|
    commands = name.camelize.constantize.commands&.keys || []
    puts "#{name}: #{commands.join(' ')}"
  end

  events = QBot.bot.instance_variable_get(:@event_handlers)
  puts "event handlers: #{events.keys.map { _1.name.demodulize }.join(' ')}"

  QBot.scheduler.shutdown
end

exit 0
