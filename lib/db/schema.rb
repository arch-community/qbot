# frozen_string_literal: true

##
# Schema of the main database used by qbot.
module Database
  # rubocop: disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
  def self.define_schema
    ActiveRecord::Schema.define(version: 2022_03_22) do # rubocop: disable Style/NumericLiterals
      create_table :server_configs do |t|
        t.integer :server_id, null: false
        t.text :prefix
        t.text :modules_json
        t.integer :log_channel_id
        t.json :options

        t.timestamps
      end

      create_table :user_configs do |t|
        t.integer :user_id, null: false
        t.json :options

        t.timestamps
      end

      create_table :queries do |t|
        t.integer :server_id, null: false
        t.integer :user_id, null: false
        t.string :text, null: false

        t.timestamps
      end

      create_table :extra_color_roles do |t|
        t.integer :server_id, null: false
        t.integer :role_id, null: false

        t.timestamps
      end

      create_table :snippets do |t|
        t.integer :server_id, null: false
        t.string :name, null: false
        t.boolean :embed
        t.string :text, null: false

        t.timestamps
      end

      create_table :rolegroups do |t|
        t.integer :server_id, null: false
        t.string :name, null: false
        t.integer :max_roles

        t.timestamps
      end

      create_table :grouped_roles do |t|
        t.belongs_to :rolegroup
        t.integer :role_id, null: false
        t.timestamps
      end

      create_table :reactions do |t|
        t.integer :message_id
        t.string :emoji
        t.integer :action_type, default: 0, null: false
        t.integer :action_target
        t.string :action_args

        t.timestamps
      end

      create_table :quotes do |t|
        t.integer :server_id, null: false
        t.integer :message_id, null: false
        t.integer :user_id, null: false
        t.text :text, null: false

        t.timestamps
      end

      create_table :blacklist_entries do |t|
        t.integer :server_id, null: false
        t.integer :channel_id, null: false
        t.string :regex, null: false

        t.timestamps
      end

      create_table :notes do |t|
        t.integer :server_id, null: false
        t.integer :user_id, null: false
        t.string :username, null: false
        t.string :name, null: false
        t.text :text, null: false

        t.timestamps
      end

      add_index :server_configs, :server_id, unique: true
      add_index :user_configs, :user_id, unique: true
      add_index :queries, :server_id
      add_index :extra_color_roles, :server_id
      add_index :snippets, :server_id

      add_index :quotes, :server_id
      add_index :quotes, :user_id

      add_index :notes, :server_id
      add_index :notes, :name

      add_index :rolegroups, :server_id
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
end
