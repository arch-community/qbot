# frozen_string_literal: true

# The queries module was deprecated in favour of forum channels
class DropQueries < ActiveRecord::Migration[7.0]
  def change
    remove_index :queries, :server_id, if_exists: true

    drop_table :queries, if_exists: true do |t|
      t.integer :server_id, null: false
      t.integer :user_id, null: false
      t.string :text, null: false

      t.timestamps
    end
  end
end
