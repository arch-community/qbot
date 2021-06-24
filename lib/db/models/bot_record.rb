# frozen_string_literal: true

##
# Base record class for all bot database storage
class BotRecord < ActiveRecord::Base
  self.abstract_class = true
end
