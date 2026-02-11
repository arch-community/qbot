# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(input)
    pp input
  end
end
