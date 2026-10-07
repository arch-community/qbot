# frozen_string_literal: true

##
# Things that get run on command execution
# TODO: replace with a proper hook registry
module Discordrb
  module Commands
    # Overrides for CommandBot
    class CommandBot
      attr_accessor :embed_target, :current_prefix

      alias execute! execute_command

      def command_exists?(name)
        command = @commands && @commands[name]
        command = command.aliased_command if command.is_a?(CommandAlias)
        !command.nil?
      end

      # rubocop: disable Style/OptionalBooleanParameter

      def execute_command(name, event, arguments, chained = false, check_permissions = true)
        args = [name, event, arguments, chained, check_permissions]

        # Called for every prefixed message, including unknown commands
        return execute!(*args) unless command_exists?(name)

        # Set the user's locale for response strings
        uc_lang = UserConfig.for(event.user.id)[:language].to_sym
        I18n.locale = uc_lang

        # Log the event
        log(event)

        # Set the default embed target
        @embed_target = event

        # Expose the current prefix
        @current_prefix = find_prefix(event.message)

        execute!(*args)
      end

      # rubocop: enable Style/OptionalBooleanParameter
    end
  end
end
