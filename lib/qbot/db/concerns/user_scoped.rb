# frozen_string_literal: true

##
# For models that have a user_id
module UserScoped
  extend ActiveSupport::Concern

  def user
    QBot.bot.user(user_id)
  end
end
