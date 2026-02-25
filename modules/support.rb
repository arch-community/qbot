# frozen_string_literal: true

##
# mrbartix
# changes the title of the support post (well, any thread)
# TODO: add tag support to this, when discordrb implements support for them
module Support
  extend Discordrb::Commands::CommandContainer
  
  # add the command
  command :solve, {
    aliases: %i[slv .],
    help_available: true,
    usage: ':solve',
    min_args: 0
  } do |event, *_|
    # check if the channel is a thread and if its closed
    next embed("That's not a thread!") unless event.channel.thread?
    next embed("This channel is already closed!") if event.channel.name.start_with?("[SOLVED]", "[DROPPED]")
    
    # change the title
    event.channel.name = "[SOLVED] #{event.channel.name}"
    embed("Success!")
  end
  command :drop, {
    aliases: %i[drp .],
    help_available: true,
    usage: ':drop',
    min_args: 0
  } do |event, *_|
    # check if the channel is a thread and if its closed
    next embed("That's not a thread!") unless event.channel.thread?
    next embed("This channel is already closed!") if event.channel.name.start_with?("[SOLVED]", "[DROPPED]")
    # change the title
    event.channel.name = "[DROPPED] #{event.channel.name}"
    embed("Success!")
  end
    command :reopen, {
    help_available: true,
    usage: ':reopen',
    min_args: 0
  } do |event, *_|
    # check if the channel is a thread and if its closed
    next embed("That's not a thread!") unless event.channel.thread?
    next embed("This channel is already closed!") unless event.channel.name.start_with?("[SOLVED]", "[DROPPED]")
    # change the title
    # removes solved or dropped from the name
    if event.channel.name.start_with?("[SOLVED]")
      event.channel.name = event.channel.name.sub("[SOLVED]", "")
    elsif event.channel.name.start_with?("[DROPPED]")
      event.channel.name = event.channel.name.sub("[DROPPED]", "")
    end
    embed("Success!")
  end
end