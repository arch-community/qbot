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

      # rubocop: disable Style/OptionalBooleanParameter

      def execute_command(name, event, arguments, chained = false, check_permissions = true)
        # Set the user's locale for response strings
        uc_lang = UserConfig.for(event.user.id)[:language].to_sym
        I18n.locale = uc_lang

        # Log the event
        log(event)

        # Set the default embed target
        @embed_target = event

        # Expose the current prefix
        @current_prefix = find_prefix(event.message)

        execute!(name, event, arguments, chained, check_permissions)
      end

      # rubocop: enable Style/OptionalBooleanParameter
    end
  end
end
