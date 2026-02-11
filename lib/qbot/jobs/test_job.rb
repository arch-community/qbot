# frozen_string_literal: true

# Test job for debugging the job queue
class TestJob < ApplicationJob
  queue_as :default

  def perform(input)
    pp input
  end
end
