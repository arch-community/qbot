# frozen_string_literal: true

# User configuration table
class UserConfig < ActiveRecord::Base
  # Cache config objects
  def self.[](uid)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[uid] ||= UserConfig.find_or_create_by(user_id: uid)
    @@configs[uid].contents ||= {}
  end

  after_save do |conf|
    @@configs.delete(conf.user_id)
    # rubocop: enable Style/ClassVars
  end
end
