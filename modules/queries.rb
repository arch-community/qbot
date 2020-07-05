module Queries
  extend Discordrb::Commands::CommandContainer

  command :query, {
    aliases: [ :q ],
    help_available: true,
    description: 'Adds a query to the list of queries',
    usage: '.q <question>',
    min_args: 1
  } do |event, *args|
    text = args.join(' ').gsub('@', "\\@\u200D")

    new_query = Query.create(server: event.server.id, author: event.author.id, text: text)
    log(event, "query id #{new_query.id}")

    event.channel.send_embed { _1.description = "Query ##{new_query.id} has been created." }
  end

  command :openqueries, {
    aliases: [ :oq ],
    help_available: true,
    description: 'Lists open queries',
    usage: '.oq',
    min_args: 0,
    max_args: 0
  } do |event, *args|
    log(event)

    Query.where("created_at <= timeout", { timeout: Time.now - 30.days }).map(&:destroy!)

    queries = Query.where(server: event.server.id).map do |q|
      { name: "##{q.id} by #{formatted_name(event.bot.user(q.author))} at #{q.created_at.to_s}", value: q.text }
    end

    queries = [{ name: '#0', value: 'No results' }] if queries.empty?

    event.channel.send_embed do |m|
      m.title = 'Open Queries'
      m.description = 'Queries are deleted after 30 days.'
      m.fields = queries || nil
    end
  end

  command :closequery, {
    aliases: [ :cq ],
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
end
