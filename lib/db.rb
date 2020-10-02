ActiveRecord::Base.logger = $applog

def init_db
  ActiveRecord::Base.establish_connection(
    adapter: $config.database.type,
    database: $config.database.db,
    username: $config.database.user,
    password: $config.database.pass
  )
  $applog.info 'Database connection initialized.'
end

def define_schema
  ActiveRecord::Schema.define(version: 2020_10_02) do
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

class Query < ActiveRecord::Base; end
class ServerConfig < ActiveRecord::Base; end
class ExtraColorRole < ActiveRecord::Base; end
class Snippet < ActiveRecord::Base; end
