# frozen_string_literal: true

module QBot
  module Database
    def self.db_name(cfg)
      if cfg.type == 'sqlite3'
        File.join(QBot.options.state_dir, cfg.db)
      else
        conf.db
      end
    end

    def self.ar_config(cfg)
      {
        adapter: cfg.type,
        database: db_name(cfg),
        username: cfg.user,
        password: cfg.pass
      }
    end
  end
end
