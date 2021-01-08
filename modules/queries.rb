# frozen_string_literal: true

# Support channel management
module Queries
  extend Discordrb::Commands::CommandContainer

  command :query, {
    aliases: [:q],
    help_available: true,
    description: 'Adds a query to the list of queries',
    usage: '.q <question>',
    min_args: 1
  } do |event, *args|
    text = args.join(' ').gsub('@', "\\@\u200D")

    new_query = Query.create(server_id: event.server.id, user_id: event.author.id, text: text)
    log(event, "query id #{new_query.id}")

    embed event, "Query ##{new_query.id} has been created."
  end

  command :openqueries, {
    aliases: [:oq],
    help_available: true,
    description: 'Lists open queries',
    usage: '.oq',
    min_args: 0,
    max_args: 0
  } do |event, *_args|
    log(event)

    Query.where('created_at <= :timeout', { timeout: Time.now - 30.days }).map(&:destroy!)

    queries = Query.where(server_id: event.server.id).map do |q|
      { name: "##{q.id} by #{formatted_name(event.bot.user(q.user_id))} at #{q.created_at}", value: q.text }
    end

    queries = [{ name: '#0', value: 'No results' }] if queries.empty?

    event.channel.send_embed do |m|
      m.title = 'Open Queries'
      m.description = 'Queries are deleted after 30 days.'
      m.fields = queries || nil
    end
  end

  command :closequery, {
    aliases: [:cq],
    help_available: true,
    description: 'Closes a query',
    usage: '.cq <id>',
    min_args: 1
  } do |event, *args|
    log(event)

    args.each do
      id = _1.to_i
      begin
        q = Query.where(server_id: event.server.id).find(id)
      rescue ActiveRecord::RecordNotFound
        event.respond "Query ##{id} not found."
      end

      if !q
        event.respond "Query ##{id} not found."
      elsif event.author.id == q.user_id \
            || event.author.permission?(:manage_messages, event.channel)
        q.destroy!
        event.respond "Deleted query ##{id}."
      else
        event.respond "You do not have permission to delete query ##{id}."
      end
    end

    nil
  end
end
