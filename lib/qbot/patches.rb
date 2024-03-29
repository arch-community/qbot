# frozen_string_literal: true

# ActiveRecord Rake jobs
module Rails
  class << self
    attr_accessor :env
  end
end

module Discordrb
  module Events
    # Wrap Respondable#send_message to allow using keyword arguments
    # rubocop: disable Metrics/ParameterLists
    module Respondable
      def respond_wrapped(content, tts: false, embed: nil, attachments: nil,
                          allowed_mentions: nil, message_reference: nil, components: nil)
        send_message(content, tts, embed, attachments, allowed_mentions, message_reference, components)
      end
    end
    # rubocop: enable Metrics/ParameterLists
  end
end

##
# StringIO derivative that presents a fake path to discordrb
class NamedStringIO < StringIO
  attr_accessor :path

  def initialize(string = '', mode = nil, path: 'image.png')
    @path = path
    super(string, mode)
  end
end

# reimplementing discordrb's ignore_bot with a whitelist
module CommandEventIntercept
  # rubocop: disable Style/OptionalBooleanParameter
  def call(event, arguments, chained = false, check_permissions = true)
    # rubocop:enable Style/OptionalBooleanParameter
    return if event.author.bot_account && !(QBot.config.bot_id_allowlist.include? event.author.id)

    super(event, arguments, chained, check_permissions)
  end
end

module Discordrb
  module Commands
    class Command
      prepend CommandEventIntercept
    end
  end
end
