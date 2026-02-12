# frozen_string_literal: true

##
# Event container for the Colors module
module ColorsEvents
  extend Discordrb::EventContainer

  # Color roles on join

  member_leave do |event|
    PendingMember.for(event.server).destroy_by(user_id: event.user.id)
  end

  def give_random_color(server, user)
    new_role = Colors::ColorRole.for(server).sample.role
    user.add_role(new_role)
  end

  member_join do |event|
    opt = ServerConfig.for(event.server)[:auto_assign_colors]

    give_random_color(event.server, event.user) if opt == 'on_join'
  end

  raw(type: :GUILD_MEMBER_ADD) do |event|
    server_id = event.data['guild_id'].to_i
    opt = ServerConfig.for(server_id)[:auto_assign_colors]

    if opt == 'on_screening_pass' && event.data['pending']
      user_id = event.data.dig('user', 'id')
      PendingMember.create!(server_id:, user_id:)
    end
  end

  raw(type: :GUILD_MEMBER_UPDATE) do |event|
    server_id = event.data['guild_id'].to_i
    opt = ServerConfig.for(server_id)[:auto_assign_colors]

    if opt == 'on_screening_pass' && event.data['pending'] == false
      user_id = event.data.dig('user', 'id')
      record = PendingMember.find_by!(server_id:, user_id:)

      server = event.bot.server(server_id)
      member = server.member(user_id)

      give_random_color(server, member)
      record.destroy!
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
