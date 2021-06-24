# frozen_string_literal: true

# User configuration table
class UserConfig < BotRecord
  # Cache config objects
  def self.[](uid)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[uid] ||= UserConfig.find_or_create_by(user_id: uid)
    @@configs[uid].contents ||= {}
    @@configs[uid]
  end

  after_save do |conf|
    @@configs.delete(conf.user_id)
    # rubocop: enable Style/ClassVars
  end
end
