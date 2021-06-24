# frozen_string_literal: true

# Helpers for the server config
class ServerConfig < BotRecord
  # Cache config objects
  def self.[](server_id)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[server_id] ||= ServerConfig.find_or_create_by(server_id:)
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
    pfx = prefix.to_s

    if prefix.nil?
      self.prefix = QBot.config.default_prefix || '.'
      save!
    end

    pfx
  end

  def all_modules?
    modules_conf['disabled'].empty?
  end

  def modules
    global = QBot.instance.all_modules
    global - modules_conf['disabled']
  end

  def disabled_modules
    modules_conf['disabled']
  end
end
