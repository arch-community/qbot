# frozen_string_literal: true

# Configurable snippets
module Quotes
  extend Discordrb::Commands::CommandContainer

  command :grab, {
    help_available: true,
    usage: '.grab @user',
    min_args: 1,
    max_args: 1,
  } do |event, target|
    target_id = event.message.mentions[0].id
    quote = event.channel.history(20, event.message.id).find { |m| m.author.id == target_id and not m.from_bot? }
    if quote
      Quote.create(server_id: event.server.id,
                   user_id: quote.author.id,
                   text: quote.content)
      embed t('quotes.grab.success')
    else
      embed t('quotes.grab.failure', target)
    end
  end

  command :listquotes, {
    help_available: true,
    usage: '.listquotes @user',
    min_args: 1,
    max_args: 1,
  } do |event, target|
    target_id = event.message.mentions[0].id
    quotes = Quote.where(server_id: event.server.id,
                        user_id: target_id)
    if !quotes || quotes.empty?
      embed t('quotes.list.empty', target)
    else
      embed quotes.map{|q| "#{q.id} : #{q.text}"}.join("\n")
    end
  end

  command :quote, {
    help_available: true,
    usage: '.quote <quote id | @user>',
    min_args: 1,
    max_args: 1,
  } do |event, quote|
    target = event.message.mentions[0]
    if target
      target_id = target.id
    end
    if /^[\d]+$/.match(quote)
      quote_id = Integer(quote)
      result = Quote.find(quote_id)
      if !result
        embed t('quotes.quote.failure', target, quote_id)
      else
        embed result.text
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
    min_args: 1,
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
end
