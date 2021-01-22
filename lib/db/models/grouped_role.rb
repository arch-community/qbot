# frozen_string_literal: true

# Role in a rolegroup
class GroupedRole < ActiveRecord::Base
  belongs_to :rolegroup
end
