# frozen_string_literal: true

# Support channel management
module Queries
  extend Discordrb::Commands::CommandContainer

  command :query, {
    aliases: [:q],
    help_available: true,
    usage: '.q <question>',
    min_args: 1
  } do |event, *args|
    text = args.join(' ').gsub('@', "\\@\u200D")

    if text.length > 1024
      embed t('queries.query.too-long')
      next
    end

    new_query = Query.create(server_id: event.server.id, user_id: event.author.id, text:)

    embed t('queries.query.success', new_query.id)
  end

  command :openqueries, {
    aliases: [:oq],
    help_available: true,
    usage: '.oq',
    min_args: 0,
    max_args: 0
  } do |event, *_args|
    Query.where('created_at <= :timeout', { timeout: Time.now - 30.days }).map(&:destroy!)

    queries = Query.where(server_id: event.server.id).map do |q|
      {
        name: t('queries.oq.entry-name',
                q.id, event.bot.user(q.user_id).distinct, q.created_at),
        value: q.text
      }
    end

    queries = [{ name: '#0', value: t('queries.oq.no-results') }] if queries.empty?

    embed do |m|
      m.title = t('queries.oq.title')
      m.description = t('queries.oq.deleted-after-30d')
      m.fields = queries || nil
    end
  end

  command :closequery, {
    aliases: [:cq],
    help_available: true,
    usage: '.cq <id>',
    min_args: 1
  } do |event, *args|
    args.each do
      id = _1.to_i
      begin
        q = Query.where(server_id: event.server.id).find(id)
      rescue ActiveRecord::RecordNotFound
        embed t('queries.cq.not-found', id)
        next
      end

      if !q
        embed t('queries.cq.not-found', id)
      elsif event.author.id == q.user_id \
            || event.author.permission?(:manage_messages, event.channel)
        q.destroy!
        embed t('queries.cq.success', id)
      else
        embed t('queries.cq.no-perms', id)
      end
    end

    nil
  end
end
