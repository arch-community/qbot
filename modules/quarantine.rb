# frozen_string_literal: true

# Quarantine module for ma pona
module Quarantine
  extend Discordrb::Commands::CommandContainer

  command :quarantine, {
    help_available: true,
    description: 'Quarantines a user',
    usage: '.quarantine <mention or user id>',
    min_args: 1
  } do |event, *args|
    unless event.author.permission?(:administrator)
      embed event, 'You do not have the required permissions for this.'
      return
    end

    uids = []
    while arg = args.shift
      p arg
      begin
        uid = Integer(arg)
        uids << uid
      rescue ArgumentError, TypeError
        next
      end
    end

    uids += event.message.mentions.map(&:id)
    uids.uniq!

    pfx = ServerConfig[event.server.id].prefix

    uids.each do |uid|
      user = event.server.member(uid)

      QBot.bot.channel(759212695978770454).send_embed do |m|
        m.title = "User quarantined"
        m.author = {
          name: "#{user.username}##{user.discriminator}",
          icon_url: user.avatar_url
        }
        m.description = "To unquarantine:\n#{pfx}restore #{uid} #{user.roles.map(&:id).join(' ')}"
        m.fields = [
          { name: 'Roles', value: user.roles.map(&:mention).join(' ') },
        ];
      end

      user.roles.each { |r|
        begin
          user.remove_role(r.id, 'Removing for quarantine') 
        rescue Discordrb::Errors::NoPermission
          next
        end
      }

      user.add_role(761568115720192030, 'Quarantine role')
    end

    return nil
  end

  command :restore, {
    help_available: true,
    description: 'Restores a user\'s roles after a quarantine',
    usage: '.help [command]',
    min_args: 1
  } do |event, uid, *roles|
    unless event.author.permission?(:administrator)
      embed event, 'You do not have the required permissions for this.'
      return
    end

    m = event.server.member(uid.to_i)
    rids = roles.map(&:to_i)

    m.set_roles(rids, 'Restoring after quarantine')
    
    embed event, "Restored #{rids.size} roles to #{m.mention}."
  end
end
