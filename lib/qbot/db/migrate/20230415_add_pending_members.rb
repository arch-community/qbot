# frozen_string_literal: true

# Add pending_members table for screening-pass color assignment
class AddPendingMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :pending_members do |t|
      t.integer :server_id, null: false
      t.integer :user_id, null: false

      t.timestamps

      t.index %i[server_id user_id], unique: true
    end
  end
end
