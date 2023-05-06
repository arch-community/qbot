# frozen_string_literal: true

##
# For models that have a server_id
module ServerScoped
  extend ActiveSupport::Concern

  included do
    scope :for, (lambda do |server|
      server_id = server.is_a?(Discordrb::Server) ? server.id : server

      where(server_id:)
    end)
  end

  def server
    QBot.bot.server(server_id)
  end
end
