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
    # TODO make this nicer. Feels like a hack.
    target_id = Integer(target[3..-2])
    event.channel.history(5, event.message.id).each { |m|
      if (m.author.id == target_id) and (not m.from_bot?)
        Quote.create(server_id: event.server.id,
                     user_id: m.author.id,
                     text: m.content)
        embed t('quotes.grab.success')
        return
      end
    }
    embed t('quotes.grab.failure', target)
  end

  command :quote, {
    help_available: true,
    usage: '.quote @user quote_id',
    min_args: 1,
    max_args: 2,
  } do |event, target, quote|
    target_id = Integer(target[3..-2])
    if quote
      quote_id = Integer(quote)
      result = Quote.find_by(server_id: event.server.id,
                            user_id: target_id,
                            id: quote_id)
      if result then embed result.text else embed t('quotes.quote.failure', target, quote_id) end
    else # return the most recent quote by default
      results = Quote.where(server_id: event.server.id,
                            user_id: target_id)
      result_id = results.maximum('id')
      result = Quote.find(result_id).text
      embed result
    end
  end

  command :rquote, {
    help_available: false,
    usage: '.rquote @user',
    min_args: 1,
    min_args: 1,
  } do |event, target|
    target_id = Integer(target[3..-2])
    random_quote = Quote.where(server_id: event.server.id,
                               user_id: target_id).order(Arel.sql('RANDOM()')).first.text
    embed random_quote
  end

  # REFER TO WIKI FOR FUNCIONALITY
  # https://wiki.archlinux.org/index.php/Phrik#Grab
  # TODO
  # - Improve on Integer() casts for IDs
end