# frozen_string_literal: true

require 'shellwords'

# Poll commands / support
module Polls
  extend Discordrb::Commands::CommandContainer

  command :poll, {
    help_available: true,
    usage: '.poll <channel> <title> <options>',
    min_args: 1
  } do |event, *args|
    log(event)

    ch, title, *opts = args.join(' ').shellsplit

    channel = event.bot.channel(ch)

    embed_msg = channel.send_embed do |m|
      m.title = title
      m.description = opts.map.with_index do |arg, idx|
        ":#{to_word(idx+1)}:#{"\u00A0"*3}#{arg}"
      end.join("\n")
    end

    opts.each.with_index do |_, idx|
      embed_msg.create_reaction to_emoji(idx + 1)
    end

    nil
  end
end
