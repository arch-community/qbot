# frozen_string_literal: true

# Entry in a channel blacklist
class BlacklistEntry < ActiveRecord::Base
  def re
    Regexp.new regex
  end
end
