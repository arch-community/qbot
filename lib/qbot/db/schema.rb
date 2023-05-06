# frozen_string_literal: true

##
# Schema of the main database used by qbot.
module Database
  # rubocop: disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
  def self.define_schema
    ActiveRecord::Schema.define(version: 2022_04_10) do # rubocop: disable Style/NumericLiterals
      create_table :server_configs do |t|
        t.integer :server_id, null: false
        t.text :prefix
        t.integer :log_channel_id
        t.json :contents, null: false, default: {}

        t.timestamps
      end

      create_table :user_configs do |t|
        t.integer :user_id, null: false
        t.json :contents, null: false, default: {}

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
        t.boolean :embed, null: false, default: true
        t.string :text, null: false

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

      create_table :pending_members do |t|
        t.integer :server_id, null: false
        t.integer :user_id, null: false

        t.timestamps

        t.index %i[server_id user_id], unique: true
      end

      create_table :delayed_jobs do |t|
        t.integer :priority, default: 0, null: false
        t.integer :attempts, default: 0, null: false
        t.text :handler, null: false
        t.text :last_error
        t.datetime :run_at
        t.datetime :locked_at
        t.datetime :failed_at
        t.string :locked_by
        t.string :queue
        t.timestamps null: true
      end

      add_index :delayed_jobs,
                %i[priority run_at],
                name: 'delayed_jobs_priority'

      add_index :server_configs, :server_id, unique: true
      add_index :user_configs, :user_id, unique: true
      add_index :queries, :server_id
      add_index :extra_color_roles, :server_id
      add_index :snippets, :server_id

      add_index :notes, :server_id
      add_index :notes, :name
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
end
