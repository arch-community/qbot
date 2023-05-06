# frozen_string_literal: true

# Support channel management
module Queries
  extend Discordrb::Commands::CommandContainer

  command :query, {
    aliases: [:q],
    help_available: true,
    usage: '.q <question>',
    min_args: 1
  } do |event, _|
    text = after_nth_word(1, event.text).gsub('@', "\\@\u200D")

    query = Query.for(event.server).create!(user_id: event.user.id, text:)

    embed t('queries.query.success', query.id)
  rescue ActiveRecord::RecordInvalid
    embed t('queries.query.failure', query.errors.full_messages.join(', '))
  end

  def self.query_field(query)
    query => { id:, created_at:, text: }

    name = t('queries.oq.entry-name', id, query.user.distinct, created_at)

    { name:, value: text }
  end

  command :openqueries, {
    aliases: [:oq],
    help_available: true,
    usage: '.oq',
    min_args: 0,
    max_args: 0
  } do |event, *_args|
    Query.destroy_by(created_at: ..(Time.now - 30.days))

    fields = Query.for(event.server).map { query_field(_1) }

    empty_field = { name: '#0', value: t('queries.oq.no-results') }
    fields << empty_field if fields.empty?

    embed do |m|
      m.title = t('queries.oq.title')
      m.description = t('queries.oq.deleted-after-30d')
      m.fields = fields
    end
  end

  command :closequery, {
    aliases: [:cq],
    help_available: true,
    usage: '.cq <id>',
    min_args: 1
  } do |event, *args|
    queries = args.map { |arg|
      id = parse_int(arg)

      begin
        Query.for(event.server).find(id)
      rescue ActiveRecord::RecordNotFound
        embed t('queries.cq.not-found', id)
        nil
      end
    }

    queries.compact.each do |q|
      can_close = \
        event.user.id == q.user_id \
        || event.user.permission?(:manage_messages, event.channel)

      next embed t('queries.cq.no-perms', q.id) unless can_close

      q.destroy!
      embed t('queries.cq.success', q.id)
    end

    nil
  end
end
