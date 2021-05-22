# frozen_string_literal: true

# Configurable snippets
module Quotes
  extend Discordrb::Commands::CommandContainer

  command :grab, {
    help_available: true,
    usage: '.grab <@user | message id>',
    min_args: 1,
    max_args: 2
  } do |event, target|
    m = event.message

    if m.mentions.empty?
      quote = event.channel.history(1, nil, nil, target.to_i).first
      target_id = quote.author.id
    else
      target_id = m.mentions[0].id
      log = event.channel.history(20, m.id)
      quote = log.find { _1.author.id == target_id and !_1.from_bot? }
    end

    if quote
      existing_quote = Quote.find(message_id: quote.id)

      if existing_quote
        embed t('quotes.grab.duplicate')
        return
      end

      saved_quote = Quote.create(server_id: event.server.id,
                                 user_id: target_id,
                                 message_id: quote.id,
                                 text: quote.content)

      embed t('quotes.grab.success', saved_quote.id)
    else
      embed t('quotes.grab.failure', target)
    end
  end

  command :listquotes, {
    help_available: true,
    usage: '.listquotes @user',
    min_args: 1,
    max_args: 1
  } do |event, target|
    target_id = event.message.mentions[0].id
    quotes = Quote.where(server_id: event.server.id,
                         user_id: target_id)
    if !quotes || quotes.empty?
      embed t('quotes.list.empty', target)
    else
      embed quotes.map{ "`#{_1.id}`: #{_1.text}" }.join("\n")
    end
  end

  command :quote, {
    help_available: true,
    usage: '.quote <quote id | @user>',
    min_args: 1,
    max_args: 1
  } do |event, quote|
    target = event.message.mentions[0]
    target_id = target.id if target
    if /^\d+$/.match(quote)
      quote_id = Integer(quote)
      if Quote.exists?(quote_id)
        embed Quote.find(quote_id).text
      else
        embed t('quotes.quote.failure', quote_id)
      end
    elsif target_id
      results = Quote.where(server_id: event.server.id,
                            user_id: target_id)
      if !results || results.empty?
        embed t('quotes.list.empty', "<@!#{target_id}>")
      else
        embed results.last.text
      end
    end
  end

  command :rquote, {
    help_available: false,
    usage: '.rquote @user',
    min_args: 1,
    max_args: 1
  } do |event, target|
    target_id = event.message.mentions[0].id
    random_quote = Quote.where(server_id: event.server.id,
                               user_id: target_id).order(Arel.sql('RANDOM()')).first
    if random_quote
      embed random_quote.text
    else
      embed t('quotes.rquote.failure', target)
    end
  end

  command :delquote, {
    help_available: true,
    usage: '.delquote <id>',
    min_args: 1,
    max_args: 1
  } do |event, qid|
  end
end
