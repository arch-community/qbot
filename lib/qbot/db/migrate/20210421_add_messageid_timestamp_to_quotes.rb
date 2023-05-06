# frozen_string_literal: true

# Adds a message ID and timestamp for quotes table
class AddMessageIDTimestampToQuotes < ActiveRecord::Migration[6.0]
  def change
    change_table :quotes do |t|
      t.integer :message_id, null: false
      t.timestamps
    end
  end
end
