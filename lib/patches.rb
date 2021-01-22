# frozen_string_literal: true

def can_run(name, event)
  m = ServerConfig[event.server.id].modules

  m.filter_map { _1.capitalize.constantize&.commands&.keys }.any? { _1.include? name }
end

# what the fuck did i write here
# rubocop: disable all
def split_message_n(msg, maxlen)
  return [] if msg.empty?

  lines = msg.lines

  tri = [*0..(lines.length - 1)].map { |i| lines.combination(i + 1).first }
  joined = tri.map(&:join)

  ideal = joined.max_by { |e| e.length > maxlen ? -1 : e.length }
  ideal_ary = ideal.length > maxlen ? ideal.chars.each_slice(maxlen).map(&:join) : [ideal]

  rest = msg[ideal.length..-1].strip
  return [] unless rest

  ideal_ary + split_message_n(rest, maxlen)
end
# rubocop: enable all

module Discordrb
  module Commands
    # Overwrite of the CommandBot to monkey patch command length
    class CommandBot
      def blockify(chunk, ric)
        if ric
          chunk.prepend '```' unless chunk&.start_with? '```'
          chunk << '```'      unless chunk&.end_with? '```'
        end
        chunk
      end

      def chunked_respond(event, result)
        rc = result&.chomp
        res_is_codeblock = rc&.start_with?('```') && rc&.end_with?('```')

        split_message_n(result, 1992).each do |chunk|
          event.respond blockify(chunk, res_is_codeblock)
        end
      end

      def drain_chain(chain, event)
        result = if @attributes[:advanced_functionality]
                   CommandChain.new(chain, self).execute(event)
                 else
                   simple_execute(chain, event)
                 end

        event.drain_into(result)
      end

      # rubocop: disable Metrics/MethodLength
      def execute_chain(chain, event)
        t = Thread.new do
          @event_threads << t
          Thread.current[:discordrb_name] = "ct-#{@current_thread += 1}"
          begin
            debug("Parsing command chain #{chain}")

            result = drain_chain(chain, event)

            if event.file
              event.send_file(event.file, caption: result)
            elsif !result&.empty?
              chunked_respond(event, result)
            end
          rescue StandardError => e
            log_exception(e)
          ensure
            @event_threads.delete(t)
          end
        end
      end
      # rubocop: enable Metrics/MethodLength

      # Check server modules on command execution
      alias execute! execute_command
      # rubocop: disable Style/OptionalBooleanParameter
      def execute_command(name, event, arguments, chained = false, check_permissions = true)
        return unless can_run(name, event)

        uc = UserConfig[event.user.id]
        lang = uc.contents && uc.contents['lang']&.to_sym || I18n.default_locale
        I18n.locale = lang

        execute!(name, event, arguments, chained, check_permissions)
      end
      # rubocop: enable Style/OptionalBooleanParameter
    end
  end
end
