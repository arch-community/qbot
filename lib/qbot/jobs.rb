# frozen_string_literal: true

# monkeypatch
module Rails
  def self.logger = Logger.new($stdout)
end

ActiveJob::Base.queue_adapter = :delayed_job

load_by_glob('jobs', '*.rb')
