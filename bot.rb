#!/usr/bin/env ruby

Bundler.require :default

token = ENV['TOKEN']
raise 'No token in environment; set TOKEN' unless token

bot = Discordrb::Commands::CommandBot.new(
  token: token,
  prefix: '.',
  command_doesnt_exist_message: 'Invalid command.'
)

bot.command :echo, {
  help_available: true,
  description: 'Echoes a string',
  usage: '.echo <string>',
  min_args: 1
} do |_e, *args|
  args.map { |a| a.gsub('@', "\\@\u200D") }.join(' ')
end

bot.run true
bot.join

