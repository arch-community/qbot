# frozen_string_literal: true

require 'shellwords'

# Poll commands / support
module Polls
  extend Discordrb::Commands::CommandContainer

  def self.channel_arg(event, args)
    m_args = args.join(' ').shellsplit
    if (channel = event.bot.channel(m_args[0]))
      m_args.shift
    else
      channel = event.channel
    end

    [channel, *m_args]
  end

  command :poll, {
    help_available: true,
    usage: '.poll [channel] <title> <options>',
    min_args: 1
  } do |event, *args|
    log(event)

    channel, title, *opts = channel_arg(event, args)

    unless event.author.permission?(:send_messages, channel)
      embed event, t(:no_perms)
      return
    end

    bot_user = event.bot.bot_user

    embed_msg = channel.send_embed do |m|
      m.author = {
        icon_url: event.author.avatar_url,
        name: event.author.username
      }
      m.title = title
      m.description = opts.map.with_index do |arg, idx|
        ":#{to_word(idx + 1)}:#{"\u00A0" * 3}#{arg}"
      end.join("\n")
      m.footer = {
        icon_url: bot_user.avatar_url,
        text: "type:poll opts:#{opts.size} / #{bot_user.username} v#{QBot.version}"
      }
    end

    opts.each.with_index do |_, idx|
      embed_msg.create_reaction to_emoji(idx + 1)
    end

    nil
  end
end

QBot.bot.reaction_add do |event|
  footer_text = event.message.embeds.first&.footer&.text
  if footer_text&.include?('type:poll') \
      && event.user.id != QBot.bot.bot_user.id
    matches = footer_text.match(/opts:(\d+)/)
    num = matches && matches[1]&.to_i

    last = num || 9
    numbers = [*1..last].map { to_emoji _1 }

    numbers.include?(event.emoji.name) || \
      event.message.delete_reaction(event.user, event.emoji)
  end
end
