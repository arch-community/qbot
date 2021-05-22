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
        # Check server modules on command execution
        return unless can_run(name, event)

        # Set the user's locale for response strings
        uc = UserConfig[event.user.id]
        lang = uc.contents && uc.contents['lang']&.to_sym || I18n.default_locale
        I18n.locale = lang

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
