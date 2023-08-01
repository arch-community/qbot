# frozen_string_literal: true

# monkeypatch
module Rails
  def self.logger = Logger.new($stdout)
end

module Delayed
  module Backend
    module ActiveRecord
      ##
      # Fix for Rails 7.1 deprecation
      # TODO remove when delayed_job_active_record updates
      class Job
        def self.db_time_now
          if Time.zone
            Time.zone.now
          elsif ::ActiveRecord.default_timezone == :utc
            Time.now.utc
          else
            Time.now
          end
        end
      end
    end
  end
end

ActiveJob::Base.queue_adapter = :delayed_job

load_by_glob('jobs', '*.rb')
