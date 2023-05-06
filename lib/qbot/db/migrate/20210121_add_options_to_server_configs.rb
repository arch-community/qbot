# frozen_string_literal: true

##
# Adds an 'options' JSON column to the server_configs table.
# This is used for storing various server settings for which adding a column
# would be too obtrusive.
class AddOptionsToServerConfigs < ActiveRecord::Migration[6.0]
  def change
    change_table :server_configs do |t|
      t.json :options
    end
  end
end
