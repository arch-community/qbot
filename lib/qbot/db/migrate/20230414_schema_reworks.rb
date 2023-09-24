# frozen_string_literal: true

class SchemaReworks < ActiveRecord::Migration[7.0]
  def change
    change_table :server_configs do |t|
      t.remove :modules_json, :text
    end

    change_table :user_configs do |t|
      t.change_null :contents, false
      t.change_default :contents, from: nil, to: {}
    end

    change_table :snippets do |t|
      t.change_default :embed, from: nil, to: true
      t.change_null :embed, false
    end

    remove_index :rolegroups, :server_id

    drop_table :rolegroups, if_exists: true do |t|
      t.integer :server_id, null: false
      t.string :name, null: false
      t.integer :max_roles

      t.timestamps
    end

    drop_table :grouped_roles, if_exists: true do |t|
      t.belongs_to :rolegroup, null: false
      t.integer :role_id, null: false
      t.timestamps
    end

    drop_table :reactions, if_exists: true do |t|
      t.integer :message_id, null: false
      t.string :emoji, null: false
      t.integer :action_type, default: 0, null: false
      t.integer :action_target, null: true
      t.string :action_args, null: true

      t.timestamps
    end

    remove_index :quotes, :server_id
    remove_index :quotes, :user_id

    drop_table :quotes, if_exists: true do |t|
      t.integer :server_id, null: false
      t.integer :message_id, null: false
      t.integer :user_id, null: false
      t.text :text, null: false

      t.timestamps
    end
  end
end
