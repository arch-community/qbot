# frozen_string_literal: true

ActiveRecord::Base.logger = QBot.log

# Database interface
module Database
  def self.init_db
    conf = QBot.config.database
    ActiveRecord::Base.establish_connection(
      adapter: conf.type,
      database: conf.db,
      username: conf.user,
      password: conf.pass
    )
    QBot.log.info 'Database connection initialized.'
  end

  # rubocop: disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
  def self.define_schema
    ActiveRecord::Schema.define(version: 2020_10_02) do # rubocop: disable Style/NumericLiterals
      create_table :server_configs do |t|
        t.integer :server_id, null: false
        t.text :prefix
        t.text :modules_json
        t.integer :log_channel_id
        t.timestamps
      end

      create_table :user_configs do |t|
        t.integer :user_id, null: false
        t.json :contents
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
        t.integer :user_id, null: false
        t.text :text, null: false
      end

      create_table :blacklist_entries do |t|
        t.integer :server_id, null: false
        t.integer :channel_id, null: false
        t.string :regex, null: false

        t.timestamps
      end

      add_index :server_configs, :server_id, unique: true
      add_index :user_configs, :user_id, unique: true
      add_index :queries, :server_id
      add_index :extra_color_roles, :server_id
      add_index :snippets, :server_id
      add_index :quotes, :server_id
      add_index :quotes, :user_id

      add_index :rolegroups, :server_id
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
end

class Query < ActiveRecord::Base; end

class ExtraColorRole < ActiveRecord::Base; end

class Snippet < ActiveRecord::Base; end

# Entry in a channel blacklist
class BlacklistEntry < ActiveRecord::Base
  def re
    Regexp.new regex
  end
end

# Reaction action
class Reaction < ActiveRecord::Base
  enum status: %i[role message command]
end

# Group of roles
class Rolegroup < ActiveRecord::Base
  has_many :grouped_roles, dependent: :destroy
end

# Rule in a rolegroup
class GroupedRole < ActiveRecord::Base
  belongs_to :rolegroup
end

# Helpers for the server config
class ServerConfig < ActiveRecord::Base
  # Cache config objects
  def self.[](server_id)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[server_id] ||= ServerConfig.find_or_create_by(server_id: server_id)
  end

  after_save do |conf|
    @@configs.delete(conf.server_id)
    # rubocop: enable Style/ClassVars
  end

  def modules_conf
    modules_json ? JSON.parse(modules_json) : { 'disabled' => [] }
  end

  def server_prefix
    unless prefix
      prefix = QBot.config.global.prefix || '.'
      save!
    end

    prefix
  end

  def modules
    global = QBot.config.global.modules
    global - modules_conf['disabled']
  end
end

# User configuration table
class UserConfig < ActiveRecord::Base
  # Cache config objects
  def self.[](uid)
    # rubocop: disable Style/ClassVars
    @@configs ||= {}
    @@configs[uid] ||= UserConfig.find_or_create_by(user_id: uid)
  end

  after_save do |conf|
    @@configs.delete(conf.user_id)
    # rubocop: enable Style/ClassVars
  end
end
