# frozen_string_literal: true

##
# Toki Pona commands
module Tokipona
  extend Discordrb::Commands::CommandContainer

  def self.tpo_field(text) = { name: 'tokipona.org', value: text }

  def self.pu_desc(query)
    dict = TPDict.instance
    res = dict.query_pu(query)

    res || t('tokipona.nimi.not-found')
  end

  command :nimi, {
    help_available: true,
    usage: '.nimi <word>',
    min_args: 1
  } do |event, *_|
    dict = TPDict.instance
    query = after_nth_word(1, event.text)

    tpo_res =
      dict.query_tp_inli(
        query,
        limit: 8,
        overflow_text: t('tokipona.nimi.overflow', :tpo)
      )

    embed do |m|
      m.title = query
      m.fields = [tpo_field(tpo_res)] if tpo_res
      m.description = pu_desc(query)
      m.footer = { text: t('tokipona.attrib.footer', :tpsources) }
    end
  end

  command :tpo, {
    help_available: true,
    usage: '.tpo <word>',
    min_args: 1
  } do |event, *_|
    dict = TPDict.instance
    query = after_nth_word(1, event.text)

    res = dict.query_tp_inli(query)

    embed do |m|
      m.title = query
      m.description = res || t('tokipona.tpo.not-found')
      m.footer = { text: t('tokipona.attrib.footer', :tpsources) }
    end
  end

  command :tpsources, {
    help_available: true,
    usage: '.tpsources',
    min_args: 0,
    max_args: 0
  } do
    embed do |m|
      m.title = t('tokipona.attrib.title')
      m.description = t('tokipona.attrib.text', TPDict.instance.sourcelist)
    end
  end
end
