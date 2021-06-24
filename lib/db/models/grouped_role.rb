# frozen_string_literal: true

# Role in a rolegroup
class GroupedRole < BotRecord
  belongs_to :rolegroup
end
