# frozen_string_literal: true

##
# Register things to be run on each command execution.
module HookRegistry
  def self.included(base)
    base.class_eval do
      attr_accessor :embed_target, :current_prefix

      class << self
        attr_reader :hooks
      end
    end

    # Make QBot.hook accessible
    base.extend(ClassMethods)
  end

  ##
  # Contains the hook method.
  module ClassMethods
    ##
    # Registers a hook that runs on each command execution.
    # Hooks are blocks that take an event.
    # If the value they return is falsy, the command does not run.
    def hook(&block)
      @hooks ||= []
      @hooks << block
    end
  end

  # rubocop: disable Style/OptionalBooleanParameter
  def execute_command(name, event, arguments, chained = false, check_permissions = true)
    self.class.hooks.each do |block|
      return unless instance_exec(event, name, &block) # rubocop: disable Lint/NonLocalExitFromIterator
    end

    super
  end
  # rubocop: enable Style/OptionalBooleanParameter
end
