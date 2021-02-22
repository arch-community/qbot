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

  def self.add_n_reacts(message, count)
    count.times do |idx|
      message.create_reaction to_emoji(idx + 1)
    end
  end

  def self.poll_body(opts)
    opts.map.with_index do |arg, idx|
      "#{to_emoji(idx + 1)}#{"\u00A0" * 3}#{arg}"
    end.join("\n")
  end

  def self.poll_footer(event, n_opts)
    bot_user = event.bot.bot_user

    {
      icon_url: bot_user.avatar_url,
      text: "type:poll opts:#{n_opts} / " \
      "#{bot_user.username} v#{QBot.version}"
    }
  end

  def self.send_poll(event, channel, title, opts)
    embed_msg = channel.send_embed do |m|
      m.title = title
      m.description = poll_body(opts)
      m.footer = poll_footer(event, opts.size)
    end

    add_n_reacts(embed_msg, opts.size)
    embed_msg
  end

  command :poll, {
    help_available: true,
    usage: '.poll [channel] <title> <options>',
    min_args: 1
  } do |event, *args|
    log(event)

    channel, title, *opts = channel_arg(event, args)

    if channel.server != event.server
      embed event, t('polls.cross-server')
      return
    end

    unless event.author.permission?(:send_messages, channel) &&
           event.channel == channel ||
           event.author.permission?(:manage_messages, channel)
      embed event, t(:no_perms)
    end

    send_poll(event, channel, title, opts)

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
