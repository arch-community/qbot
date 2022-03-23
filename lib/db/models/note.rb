# frozen_string_literal: true

# Note
class Note < ActiveRecord::Base
  validates :name, length: { maximum: 32 }
  validates :text, length: { minimum: 1, maximum: 2000 }
end
