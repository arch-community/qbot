# frozen_string_literal: true

##
# Notes (like Nadeko's quotes)
# rubocop: disable Metrics/ModuleLength
module Notes
  extend Discordrb::Commands::CommandContainer

  command :addnote, {
    aliases: %i[an .],

    help_available: true,
    usage: '.addnote <name> <text>',
    min_args: 2,
    arg_types: [String, String]
  } do |event, name, *_|
    text = event.content.sub(/^#{prefixed ''}(addnote|an|\.)\s\w+/, '').lstrip

    note = Note.create(
      server_id: event.server.id,
      user_id: event.author.id,
      username: event.author.distinct,
      name: name.downcase,
      text:
    )

    if note.valid?
      embed t('notes.add.success', note.name, note.id)
    else
      embed t('notes.add.failure', note.errors.full_messages.join(', '))
    end
  end

  command :note, {
    aliases: %i[n ..],

    help_available: true,
    usage: '.note <name>',
    min_args: 1,
    arg_types: [String]
  } do |event, name, *rest|
    name = [name, *rest].join(' ')

    notes = Note.where(
      server_id: event.server.id,
      name: name.downcase
    )

    if notes.empty?
      embed t('notes.get.failure', name)
      return
    end

    note = notes.sample
    event.respond_wrapped "**`##{note.id}`**  📣  #{note.text}", allowed_mentions: false
  end

  command :listnotes, {
    aliases: %i[liqu ln],

    help_available: true,
    usage: '.listnotes [page]',
    min_args: 0,
    max_args: 1,
    arg_types: [Integer]
  } do |event, page|
    page ||= 1
    page_size = 20

    server_notes = Note.where(server_id: event.server.id)
    max_page = (server_notes.count / page_size.to_f).ceil

    unless (1..max_page).include? page
      embed t('notes.list.invalid-page', page, max_page)
      return
    end

    notes = server_notes
            .limit(page_size)
            .offset((page - 1) * page_size)

    list = notes
           .map { t('notes.list.row', _1.id, _1.name, _1.username) }
           .join("\n")

    embed list do |m|
      m.title = t('notes.list.title', page, max_page)
    end
  end

  command :noteid, {
    aliases: %i[qid nid],

    help_available: true,
    usage: '.noteid <id>',
    min_args: 1,
    max_args: 1,
    arg_types: [Integer]
  } do |event, id|
    note = Note.find_by(id:, server_id: event.server.id)

    unless note
      embed t('notes.id.failure', id)
      return
    end

    embed note.text do |m|
      m.title = t('notes.id.title', note.name, note.id, note.username)
    end
  end

  command :delnote, {
    aliases: %i[qdel dn],

    help_available: true,
    usage: '.delnote <id>',
    min_args: 1,
    max_args: 1,
    arg_types: [Integer]
  } do |event, id|
    note = Note.find_by(id:, server_id: event.server.id)

    unless note
      embed t('notes.del.not-found', id)
      return
    end

    unless note.user_id == event.user.id ||
           event.user.permission?(:manage_messages)
      embed t('notes.del.no-perms', id)
      return
    end

    name = note.name
    id = note.id
    note.destroy
    embed t('notes.del.success', name, id)
  end

  command :exportnotes, {
    help_available: false,
    usage: '.exportnotes',
    min_args: 0,
    max_args: 0
  } do |event|
    unless event.author.permission?(:administrator) ||
           event.author.id == QBot.config.owner
      embed t('no_perms')
      return
    end

    notes = Note.where(server_id: event.server.id)

    event.send_file(StringIO.new(notes.to_json), filename: 'notes.json')
  end
end
# rubocop: enable Metrics/ModuleLength
