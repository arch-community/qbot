# frozen_string_literal: true

class RemoveBlacklist < ActiveRecord::Migration[7.0]
  def change
    remove_index :blacklist_entries, :server_id, if_exists: true
    remove_index :blacklist_entries, :channel_id, if_exists: true

    drop_table :blacklist_entries, if_exists: true do |t|
      t.integer :server_id, null: false
      t.integer :channel_id, null: false
      t.string :regex, null: false

      t.timestamps
    end
  end
end
