#!/usr/bin/env ruby

Bundler.require :default
require './lib/patches'

token = ENV['TOKEN']
raise 'No token in environment; set TOKEN' unless token

ActiveRecord::Base.logger = Logger.new(STDERR)

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

bot.command :q, {
  help_available: true,
  description: 'Adds a query to the list of queries',
  usage: '.q <question>',
  min_args: 1
} do |event, *args|
  text = args.map { |a| a.gsub('@', "\\@\u200D") }.join(' ')
  author = event.author.id

  puts "author #{author} text #{text} at #{Time.now}"
  new_query = Query.create(author: author, text: text)
  p new_query

  "New support query added to the list."
end

def name_cache_lookup(server, id)
  @cache ||= {}
  if @cache[id]
    @cache[id]
  else
    member = server.members.find { |m| m.id == id }
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
  c = event.channel

  queries = Query.all.map do |q|
    formatted_name = name_cache_lookup(event.server, q.author)
    Discordrb::Webhooks::EmbedField.new(
      name: "##{q.id} by #{formatted_name} at #{q.created_at.to_s}",
      value: q.text
    )
  end
  if queries.empty?
    queries = [Discordrb::Webhooks::EmbedField.new(
      name: "No queries found",
      value: "None found"
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
bot.join
