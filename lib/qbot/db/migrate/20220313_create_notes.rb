# frozen_string_literal: true

# Adds the notes table
class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.integer :server_id, null: false
      t.integer :user_id, null: false
      t.string :username, null: false
      t.string :name, null: false
      t.text :text, null: false

      t.timestamps
    end

    add_index :notes, :server_id
    add_index :notes, :name
  end
end
