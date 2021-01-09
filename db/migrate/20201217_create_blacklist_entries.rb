# frozen_string_literal: true

# Adds a table for blacklist entries to the database.
class CreateBlacklistEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :blacklist_entries do |t|
      t.integer :server_id, null: false
      t.integer :channel_id, null: false
      t.string :regex, null: false

      t.timestamps
    end

    add_index :blacklist_entries, :server_id
    add_index :blacklist_entries, :channel_id
  end
end
