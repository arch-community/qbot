#!/usr/bin/env ruby

Bundler.require :default
require './lib/patches'
require 'yaml'

$config = YAML.load File.read 'config.yml' || {}

token = $config['token']
raise 'No token in configuration; set token' unless token

client_id = $config['client_id']
raise 'No client_id in configuration; set client_id' unless client_id


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
        t.column :server, :integer
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

def log_command(bot, name, event, args, extra = nil)
  user = event.author
  username = name_cache_lookup(bot, user.id)
  command = name.to_s
  arguments = args.join ' '
  lc = $config['servers'][event.server.id]['log-channel']
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

  new_query = Query.create(server: event.server, author: author, text: text)
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

  queries = Query.where(server: c.server.id).map do |q|
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

bot.command :c, {
  help_available: true,
  description: 'Sets your user color',
  usage: '.c <color>',
  min_args: 1,
} do |event, *args|
  log_command(bot, :c, event, args)

  colors_all = $config['servers'][event.server.id]['roles']['colors']
  default = colors_all['default']
  extra = colors_all['extra']
  colors = default + extra
  colors.each { |c| c['role'] = event.server.roles.find { |r| r.id == c['id'] } }

  req = args.join(' ')

  user_colors = event.author.roles.filter { |r| colors.map { |c| c['id'] }.include? r.id }

  requested_color = nil
  if req.to_i.to_s == req
    requested_color = colors.find { |c| c['index'] == req.to_i } || colors.find { |c| c['id'] == req.to_i }
  else
    requested_color = colors.find { |c| c['name'].downcase.start_with? req.downcase } || nil
  end

  if requested_color == nil
    event.respond 'Color not found.'
    return
  elsif event.author.roles.include? requested_color['role']
    event.respond 'You already have that color.'
    return 
  else
    user_colors.each { |c| event.author.remove_role(c) }
    event.author.add_role requested_color['role']
    event.respond "You now have the #{requested_color['name']} color."
  end
end

bot.command :lc, {
  help_available: true,
  description: 'Lists colors',
  usage: '.lc',
  min_args: 0,
  max_args: 0
} do |event, *args|
  log_command(bot, :lc, event, args)

  colors_all = $config['servers'][event.server.id]['roles']['colors']
  default = colors_all['default']
  extra = colors_all['extra']
  colors = default + extra
  colors.each { |c| c['role'] = event.server.roles.find { |r| r.id == c['id'] } }

  message = "All colors:\n```\n"
  colors.sort_by { |c| c['index'] }.each do |c|
    message += "#{c['index'].to_s.rjust(2)}: ##{c['role'].color.hex} #{c['name']}\n"
  end
  message += '```'

  event.respond message
end

bot.member_join do |event|
  colors = $config['servers'][event.server.id]['roles']['colors']['default']
  colors.each { |c| c['role'] = event.server.roles.find { |r| r.id == c['id'] } }

  event.user.add_role(colors.sample(1)[0]['role'])
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
