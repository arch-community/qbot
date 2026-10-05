# frozen_string_literal: true

##
# Try It Online support
module Tio
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  def self.walk_tree(tree)
    tree.flat_map { |elem|
      elem.children.empty? ? [elem] : walk_tree(elem.children)
    }
  end

  def self.get_codespans(text)
    doc = Kramdown::Document.new(text, input: 'GFM')

    rc = doc.root.children

    walk_tree(rc)
      .filter { %i[codespan codeblock].include?(_1.type) }
      .map(&:value)
  end

  command :tio, {
    help_available: true,
    description: 'Evaluates code using Try It Online',
    usage: '.tio <lang> ```<code>``` [```input```]',
    min_args: 1
  } do |event, lang, *_args|
    code, input = get_codespans(event.message.text)
    next embed t('tio.no-code') if code.nil?

    raw_res = TIO.run(lang, code, nil, input)[0]
                 .encode('UTF-8', invalid: :replace, undef: :replace, replace: '�')
    res = raw_res.gsub('```', '\\```').gsub('@', "\\@\u200D")
    msg = embed "```\n#{res}\n```" do |m|
      m.footer = { text: "tio:#{event.user.id}" }
    end

    msg.create_reaction('❌')
  end

  command :tiolangs, {
    help_available: true,
    usage: '.tiolangs [category]',
    min_args: 0,
    max_args: 1
  } do |_, cat|
    langs = cat ? (TIO.languages_by_category(cat) || []) : TIO.languages

    embed langs.keys.join(', ').truncate(2048)
  end
end

module TioEvents
  extend Discordrb::EventContainer

  reaction_add(emoji: '❌') do |event|
    if (ftext = event.message.embeds.first&.footer&.text) \
        && ftext.start_with?('tio:') \
        && event.user.id != event.bot.bot_user.id
      matches = ftext.match(/tio:(\d+)/)

      id = matches && matches[1]&.to_i

      event.message.delete if event.user.id == id
    end
  end
end

module Tio
  include! TioEvents
end
