#!/usr/bin/env ruby

Bundler.require :default
# require './lib/patches'
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

def log(event, extra = nil)
  user = event.author
  username = formatted_name(event.author)

  chan_id = $config['servers'][event.server.id]['log-channel']

  Log4r::Logger['bot'].info("command execution by #{username}: #{event.message}" + (extra ? "; #{extra}" : ''))

  if chan_id
    event.bot.channel(chan_id).send_embed do |m|
      m.author = { name: username, icon_url: user.avatar_url }
      m.title = 'Command execution'
      m.fields = [
        { name: "Command", value: "#{event.message}" },
        { name: "User ID", value: user.id, inline: true },
        extra ? { name: "Information", value: extra } : nil
      ].compact
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
  log(event)
  args.join(' ').gsub('@', "\\@\u200D")
end

bot.command :q, {
  help_available: true,
  description: 'Adds a query to the list of queries',
  usage: '.q <question>',
  min_args: 1
} do |event, *args|
  text = args.join(' ').gsub('@', "\\@\u200D")

  new_query = Query.create(server: event.server, author: event.author.id, text: text)
  log(event, "query id #{new_query.id}")

  "Query ##{new_query.id} has been created."
end

def formatted_name(u)
  "#{u.name}##{u.discriminator}"
end

bot.command :oq, {
  help_available: true,
  description: 'Lists open queries',
  usage: '.oq',
  min_args: 0,
  max_args: 0
} do |event, *args|
  log(event)

  queries = Query.where(server: event.server.id).map do |q|
    q.destroy! if q.created_at < Time.now - 30.days
    { name: "##{q.id} by #{formatted_name(bot.user(q.user))} at #{q.created_at.to_s}", value: q.text }
  end

  queries = [{ name: "No queries found" }] if queries.empty?

  event.channel.send_embed do |e|
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
  log(event)

  args.each do
    id = _1.to_i
    begin
      q = Query.find(id)
    rescue ActiveRecord::RecordNotFound
      event.respond "Query ##{id} not found."
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

def get_colors(event)
  colors_all = $config['servers'][event.server.id]['roles']['colors']
  default = colors_all['default']
  extra = colors_all['extra']
  colors = default + extra
  colors.each { _1['role'] = event.server.role(_1['id']) }

  return colors, default, extra
end

bot.command :c, {
  help_available: true,
  description: 'Sets your user color',
  usage: '.c <color>',
  min_args: 1,
} do |event, *args|
  log(event)

  colors, _ = get_colors(event)

  req = args.join(' ')

  user_colors = event.author.roles & colors.map { _1['role'] }

  requested_color = nil
  if (idx = req.to_i) != 0
    requested_color = colors.find { _1['index'] == idx }
  else
    requested_color = colors.find { _1['name'].downcase.start_with? req.downcase }
  end

  rc = requested_color['role'] || (return 'Color not found.')

  if user_colors.include? rc
    'You already have that color.'
  else
    user_colors.each { event.author.remove_role(_1) }
    event.author.add_role rc
    "Your color is now **#{rc.name}**."
  end
end

bot.command :lc, {
  help_available: true,
  description: 'Lists colors',
  usage: '.lc',
  min_args: 0,
  max_args: 0
} do |event, *args|
  log(event)

  colors, _ = get_colors(event)

  list = colors.sort_by { _1['index'] }.map do |c|
    idx = c['index'].to_s.rjust(2)
    r = c['role']
    "#{idx}: ##{r.color.hex} #{r.name}"
  end

  "All colors:\n```#{list.join ?\n}```"
end

bot.member_join do |event|
  _, default, _ = get_colors(event)

  event.user.add_role(default.sample['role'])
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
