# frozen_string_literal: true

require 'active_support'
require 'active_record'
require 'jsi'

require_relative 'lib/qbot'

module ARConfig
  include ActiveRecord::Tasks

  def self.setup_env
    class << QBot
      attr_accessor :options
    end

    QBot.options = QBot::Options.new
    QBot.init_log
    QBot.init_config
    QBot::Database.init_db
  end

  def self.db_config
    QBot::Database.ar_config(QBot.config.database)
  end

  def self.setup
    setup_env

    DatabaseTasks.env = :development
    DatabaseTasks.db_dir = File.join(__dir__, *%w[lib qbot db])
    DatabaseTasks.root = __dir__

    DatabaseTasks.migrations_paths = \
      File.join(__dir__, *%w[lib qbot db migrate])

    DatabaseTasks.database_configuration = { development: db_config }

    DatabaseTasks.seed_loader = QBot::Database

    ActiveRecord.suppress_multiple_database_warning = true
  end
end

task :environment do
  ActiveSupport.on_load(:before_initialize)
  ARConfig.setup
end

load 'active_record/railties/databases.rake'
