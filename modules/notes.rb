# frozen_string_literal: true

##
# Notes (like Nadeko's quotes)
# rubocop: disable Metrics/ModuleLength
module Notes
  extend Discordrb::Commands::CommandContainer

  def self.parse_args_addnote(text)
    # matches inputs:
    #     name text
    #     "name with spaces" text
    #     'name with spaces' text
    re = /^(?<quote>['"]?)(?<name>(?:(?!\k<quote>).)+?)\k<quote>\s(?<text>.+)$/

    case re.match(text)
    in { name:, text: }
      { name: name.strip.downcase, text: text.strip }
    else
      nil
    end
  end

  command :addnote, {
    aliases: %i[an .],
    help_available: true,
    usage: '.addnote <name> <text>',
    min_args: 2
  } do |event, *_|
    rest = after_nth_word(1, event.text)
    args = parse_args_addnote(rest)

    next embed t('notes.add.invalid-args') unless args

    args => { name:, text: }

    note = Note.for(event.server).create!(
      user_id: event.user.id,
      username: event.user.distinct,
      name:,
      text:
    )

    embed t('notes.add.success', note.name, note.id)
  rescue ActiveRecord::RecordInvalid
    embed t('notes.add.failure', note.errors.full_messages.join(', '))
  end

  command :note, {
    aliases: %i[n ..],

    help_available: true,
    usage: '.note <name>',
    min_args: 1,
    arg_types: [String]
  } do |event, *_|
    query = after_nth_word(1, event.text)
    note = Note.for(event.server).find_random!(query)

    event.respond_wrapped(
      "**`##{note.id}`**  📣  #{note.text}",
      allowed_mentions: false
    )
  rescue ActiveRecord::RecordNotFound
    next
  end

  def self.format_notes_page(notes)
    notes
      .map { |n| t('notes.list.row', n.id, n.name, n.username) }
      .join("\n")
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

    server_notes = Note.for(event.server)
    entries = server_notes.page!(page - 1)

    embed do |m|
      m.title = t('notes.list.title', page, server_notes.page_count)
      m.description = format_notes_page(entries)
    end

  rescue ActiveRecord::RangeError
    embed t('notes.list.invalid-page', page, server_notes.page_count)
  end

  command :noteid, {
    aliases: %i[qid nid],

    help_available: true,
    usage: '.noteid <id>',
    min_args: 1,
    max_args: 1,
    arg_types: [Integer]
  } do |event, id|
    note = Note.for(event.server).find_by!(id:)

    embed do |m|
      m.title = t('notes.id.title', note.name, note.id, note.username)
      m.description = note.text
    end
  rescue ActiveRecord::RecordNotFound
    embed t('notes.id.failure', id)
  end

  command :delnote, {
    aliases: %i[qdel dn],

    help_available: true,
    usage: '.delnote <id>',
    min_args: 1,
    max_args: 1,
    arg_types: [Integer]
  } do |event, id|
    note = Note.for(event.server).find_by!(id:)

    next embed t('notes.del.no-perms', id) \
      unless note.user_id == event.user.id ||
             event.user.permission?(:manage_messages)

    note.destroy!
    embed t('notes.del.success', note.name, note.id)

  rescue ActiveRecord::RecordNotFound
    embed t('notes.del.not-found', id)
  end

  command :exportnotes, {
    help_available: false,
    usage: '.exportnotes',
    min_args: 0,
    max_args: 0
  } do |event|
    next embed t('no_perms') \
      unless event.author.permission?(:administrator) ||
             event.author.id == QBot.config.owner

    event.send_file(
      StringIO.new(Note.for(event.server).to_json),
      filename: 'notes.json'
    )
  end
end
# rubocop: enable Metrics/ModuleLength
