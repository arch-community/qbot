# frozen_string_literal: true

# Reaction action
class Reaction < ActiveRecord::Base
  enum status: %i[role message command]
end
