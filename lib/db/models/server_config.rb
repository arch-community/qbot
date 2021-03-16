# frozen_string_literal: true

# Helpers for the server config
class ServerConfig < ActiveRecord::Base
  # Cache config objects
  def self.[](server_id)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[server_id] ||= ServerConfig.find_or_create_by(server_id: server_id)
    @@configs[server_id].options ||= {}
    @@configs[server_id]
  end

  after_save do |conf|
    @@configs.delete(conf.server_id)
    # rubocop: enable Style/ClassVars
  end

  def modules_conf
    modules_json ? JSON.parse(modules_json) : { 'disabled' => [] }
  end

  def server_prefix
    pfx = prefix.dup

    if prefix.nil?
      self.prefix = QBot.config.global.prefix || '.'
      save!
    end

    pfx
  end

  def modules
    global = QBot.config.global.modules
    global - modules_conf['disabled']
  end
end
