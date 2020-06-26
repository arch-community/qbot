module Queries
  extend Discordrb::Commands::CommandContainer

  command :oq, {
    help_available: true,
    description: 'Lists open queries',
    usage: '.oq',
    min_args: 0,
    max_args: 0
  } do |event, *args|
    log(event)

    queries = Query.where(server: event.server.id).map do |q|
      q.destroy! if q.created_at < Time.now - 30.days
      { name: "##{q.id} by #{formatted_name(event.bot.user(q.user))} at #{q.created_at.to_s}", value: q.text }
    end

    queries = [{ name: "No queries found" }] if queries.empty?

    event.channel.send_embed do |e|
      e.title = "Open Queries"
      e.fields = queries
    end
  end

  command :cq, {
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
