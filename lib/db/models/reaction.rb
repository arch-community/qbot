# frozen_string_literal: true

# Reaction action
class Reaction < BotRecord
  enum status: %i[role message command]
end
