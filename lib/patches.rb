def can_run(name, event)
  m = ServerConfig[event.server.id].modules

  m.filter_map { (eval _1.capitalize)&.commands&.keys }.flatten.include? name
end

def split_message_n(msg, n)
  return [] if msg.empty?

  lines = msg.lines

  tri = [*0..(lines.length - 1)].map { |i| lines.combination(i + 1).first }
  joined = tri.map(&:join)

  ideal = joined.max_by { |e| e.length > n ? -1 : e.length }
  ideal_ary = ideal.length > n ? ideal.chars.each_slice(n).map(&:join) : [ideal]

  rest = msg[ideal.length..-1].strip
  return [] unless rest

  ideal_ary + split_message_n(rest, n)
end

module Discordrb::Commands
  # Overwrite of the CommandBot to monkey patch command length
  class CommandBot
    def execute_chain(chain, event)
      t = Thread.new do
        @event_threads << t
        Thread.current[:discordrb_name] = "ct-#{@current_thread += 1}"
        begin
          debug("Parsing command chain #{chain}")
          result = @attributes[:advanced_functionality] ? CommandChain.new(chain, self).execute(event) : simple_execute(chain, event)
          result = event.drain_into(result)

          if event.file
            event.send_file(event.file, caption: result)
          else
            unless result.nil? || result.empty?
              split_message_n(result, 1992).each do |chunk|
                chunk.prepend "```\n" if result && result.chomp.start_with?('```') && !chunk.start_with?('```')
                chunk << "```\n" if result && result.chomp.end_with?('```') && !chunk.end_with?('```')
                event.respond chunk
              end
            end
          end
        rescue StandardError => e
          log_exception(e)
        ensure
          @event_threads.delete(t)
        end
      end
    end

    # Check server modules on command execution
    alias execute! execute_command
    def execute_command(name, event, arguments, chained = false, check_permissions = true)
      return unless can_run(name, event)

      execute!(name, event, arguments, chained, check_permissions)
    end
  end
end
