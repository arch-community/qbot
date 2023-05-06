# frozen_string_literal: true

# Helpers for the server config
class ServerConfig < ActiveRecord::Base
  include Configurable

  def self.for(server)
    server_id = server.is_a?(Discordrb::Server) ? server.id : server

    find_or_create_by(server_id:)
  end

  def server_prefix
    if prefix.nil?
      self.prefix = QBot.config.default_prefix
      save!
    end

    prefix
  end
end
