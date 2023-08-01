# frozen_string_literal: true

# Configurable snippets
module Snippets
  extend Discordrb::Commands::CommandContainer

  def self.match_by_abbrev(strings, target)
    query = target&.strip&.downcase
    strings.abbrev[query]
  end

  def self.list_snippets(server)
    records = Snippet.for(server)

    list = records.pluck(:name).map { "`#{_1}`" }.join(', ')

    embed do |m|
      m.title = t('snippets.list.title')
      m.description = records.any? ? list : t('snippets.list.none-found')
    end
  end

  def self.set_snippet(server, name, text)
    record = Snippet.for(server).find_or_initialize_by(name:)
    record.text = text
    record.save!

    embed t('snippets.edit.success', name)
  end

  def self.destroy_snippet(server, name)
    Snippet.for(server).destroy_by(name:)
    embed t('snippets.remove.success', name)
  end

  # rubocop: disable Metrics/MethodLength
  def self.set_snippet_property(server, property, name, new_value)
    valid_properties = %w[embed]
    target = match_by_abbrev(valid_properties, property)

    return property_help(valid_properties) unless target

    record = Snippet.for(server).find_by!(name:)

    case target
    when 'embed'
      val = ActiveModel::Type::Boolean.new.cast(new_value)
      record.embed = val
      record.save!
    end

    embed t('snippets.prop.success', target, name, new_value)
  rescue ActiveRecord::RecordNotFound
    embed t('snippets.edit.not-found', name)
  end
  # rubocop: enable Metrics/MethodLength
  
  def self.property_help(valid_properties)
    embed t('snippets.prop.help', valid_properties)
  end

  def self.snippet_help
    embed t('snippets.help')
  end

  command :snippets, {
    help_available: true,
    usage: '.snippets <command>',
    min_args: 0
  } do |e, *args|
    can_manage = e.author.permission?(:manage_emojis)

    manage_verbs = %w[set edit remove rm delete property]
    verbs = %w[list show] + manage_verbs

    verb = match_by_abbrev(verbs, args.shift)

    next embed t('no_perms') if manage_verbs.include?(verb) && !can_manage

    case verb
    when 'list', 'show'
      list_snippets(e.server)

    when 'set', 'edit'
      name = args.shift
      value = after_nth_word(3, e.message.text)

      set_snippet(e.server, name, value)

    when 'remove', 'rm', 'delete'
      name = args.shift

      destroy_snippet(e.server, name)

    when 'property'
      property, name, value = args.shift, args.shift, args.shift

      set_snippet_property(e.server, property, name, value)

    else
      snippet_help
    end
  end

  command :listsnippets, {
    aliases: [:ls],
    help_available: true,
    usage: '.ls',
    min_args: 0,
    max_args: 0
  } do |event|
    list_snippets(event.server)
  end

  command :getsnippet, {
    aliases: %i[gs snippet s],
    help_available: true,
    usage: '.s <snippet name>',
    min_args: 1,
    max_args: 1
  } do |event, name|
    snippet = Snippet.for(event.server).find_by!(name:)

    if snippet.embed
      embed snippet.text
    else
      event.respond snippet.text
    end
  rescue ActiveRecord::RecordNotFound
    embed t('snippets.snippet.not-found')
  end
end
