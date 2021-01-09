# frozen_string_literal: true

# Creates a table for user configurations
class CreateUserConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_configs do |t|
      t.integer :user_id, null: false
      t.json :contents
      t.timestamps
    end

    add_index :user_configs, :user_id, unique: true
  end
end
