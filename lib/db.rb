# frozen_string_literal: true

ActiveRecord::Base.logger = QBot.log

# Database interface
module Database
  def self.init_db
    ActiveRecord::Base.establish_connection(
      adapter: @config.database.type,
      database: @config.database.db,
      username: @config.database.user,
      password: @config.database.pass
    )
    QBot.log.info 'Database connection initialized.'
  end

  # rubocop: disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
  def define_schema
    ActiveRecord::Schema.define(version: 20_201_002) do
      create_table :server_configs do |t|
        t.integer :server_id, null: false
        t.text :prefix
        t.text :modules_json
        t.integer :log_channel_id
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
        t.integer :name, null: false
        t.string :text, null: false
        t.timestamps
      end

      add_index :server_configs, :server_id, unique: true
      add_index :queries, :server_id, unique: true
      add_index :extra_color_roles, :server_id, unique: true
      add_index :snippets, :server_id, unique: true
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
end

class Query < ActiveRecord::Base; end

# Helpers for the server config
class ServerConfig < ActiveRecord::Base
  # Cache config objects
  def self.[](server_id)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[server_id] ||= ServerConfig.find_or_create_by(server_id: server_id)
  end

  def self.drop_from_cache(server_id)
    @@configs.delete(server_id)
    # rubocop: enable Style/ClassVars
  end

  def modules_conf
    @modules_json ? JSON.parse(@modules_json) : { disabled: [] }
  end

  def modules
    global = QBot.config.global.modules
    global - modules_conf[:disabled]
  end
end

class ExtraColorRole < ActiveRecord::Base; end
class Snippet < ActiveRecord::Base; end
