# frozen_string_literal: true

# User configuration table
class UserConfig < ActiveRecord::Base
  include Configurable

  def self.for(user)
    user_id = user.is_a?(Discordrb::User) ? user.id : user
    find_or_create_by(user_id:)
  end
end
