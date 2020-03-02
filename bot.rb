#!/usr/bin/env ruby

Bundler.require :default
require './lib/patches'
require 'yaml'

token = ENV['TOKEN']
raise 'No token in environment; set TOKEN' unless token

$config = YAML.load File.read 'config.yml' || {}

applog = Log4r::Logger.new 'bot'
applog.outputters = Log4r::Outputter.stderr
ActiveRecord::Base.logger = applog

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/database.sqlite3'
)

def define_schema
  ActiveRecord::Schema.define do
      create_table :queries do |t|
        t.column :author, :integer
        t.column :text, :string
        t.timestamps
      end
  end
end

class Query < ActiveRecord::Base
end


bot = Discordrb::Commands::CommandBot.new(
  token: token,
  prefix: '.'
)

def log_command(bot, name, event, args, extra = nil)
  user = event.author
  username = name_cache_lookup(bot, user.id)
  command = name.to_s
  arguments = args.join ' '
  lc = $config['log-channel']
  puts lc

  string = "command execution by #{username}: .#{command} #{arguments}"
  if extra
    string << "; #{extra}"
  end
  Log4r::Logger['bot'].info string

  if lc
    log_channel = bot.channel(lc)
    log_channel.send_embed do |m|
      m.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: username,
        icon_url: user.avatar_url
      )
      m.title = 'Command execution'
      m.fields = [
        Discordrb::Webhooks::EmbedField.new(
          name: "Command",
          value: "#{command} #{arguments}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: "User ID",
          value: user.id,
          inline: true
        )
      ]
      if extra
        m.fields += Discordrb::Webhooks::EmbedField.new(
          name: "Information",
          value: extra
        )
      end
      m.timestamp = Time.now
    end
  end
end

bot.command :echo, {
  help_available: true,
  description: 'Echoes a string',
  usage: '.echo <string>',
  min_args: 1
} do |event, *args|
  log_command(bot, :echo, event, args)
  args.map { |a| a.gsub('@', "\\@\u200D") }.join(' ')
end

bot.command :q, {
  help_available: true,
  description: 'Adds a query to the list of queries',
  usage: '.q <question>',
  min_args: 1
} do |event, *args|
  text = args.map { |a| a.gsub('@', "\\@\u200D") }.join(' ')
  author = event.author.id

  new_query = Query.create(author: author, text: text)
  log_command(bot, :q, event, args, "query id #{new_query.id}")

  "Query ##{new_query.id} has been created."
end

def name_cache_lookup(bot, id)
  @cache ||= {}
  if @cache[id]
    @cache[id]
  else
    member = bot.user(id)
    formatted_name = "#{member.name}##{member.discriminator}"
    @cache[id] = formatted_name
  end
end

bot.command :oq, {
  help_available: true,
  description: 'Lists open queries',
  usage: '.oq',
  min_args: 0,
  max_args: 0
} do |event, *args|
  log_command(bot, :oq, event, args)
  c = event.channel

  queries = Query.all.map do |q|
    formatted_name = name_cache_lookup(bot, q.author)
    Discordrb::Webhooks::EmbedField.new(
      name: "##{q.id} by #{formatted_name} at #{q.created_at.to_s}",
      value: q.text
    )
  end
  if queries.empty?
    queries = [Discordrb::Webhooks::EmbedField.new(
      name: "No queries found"
    )]
  end

  c.send_embed do |e|
    e.title = "Open Queries"
    e.fields = queries
  end
end

bot.command :cq, {
  help_available: true,
  description: 'Closes a query',
  usage: '.cq <id>',
  min_args: 1,
} do |event, *args|
  log_command(bot, :cq, event, args)
  args.each do |a|
    id = a.to_i
    begin
      q = Query.find(id)
    rescue ActiveRecord::RecordNotFound
      event.respond "Query ##{id} not found."
      return
    end

    if not q
      event.respond "Query ##{id} not found."
    else
      if event.author.id == q.author \
          or event.author.permission?(:manage_messages, event.channel)
        q.destroy!
        event.respond "Deleted query ##{id}."
      else
        event.respond "You do not have permission to delete query ##{id}."
      end
    end
  end
  nil
end

bot.run true

while buf = Readline.readline('% ', true)
  s = buf.chomp
  if s.start_with? 'quit', 'stop'
    bot.stop
    exit
  elsif s.start_with? 'restart'
    bot.stop
    exec 'ruby', $PROGRAM_NAME
  elsif s.start_with? 'irb'
    binding.irb
  elsif s == ''
    next
  else
    puts 'Command not found'
  end
end

bot.join
