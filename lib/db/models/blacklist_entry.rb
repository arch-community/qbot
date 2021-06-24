# frozen_string_literal: true

# Entry in a channel blacklist
class BlacklistEntry < BotRecord
  def re
    Regexp.new(regex)
  end
end
