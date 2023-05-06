# frozen_string_literal: true

##
# Support questions
class Query < ActiveRecord::Base
  include ServerScoped
  include UserScoped

  validates :text, length: { maximum: 1024 }
end
