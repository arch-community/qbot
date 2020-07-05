def can_run(name, event)
  if (m = $config.servers[event.server.id]&.modules)
    m.filter_map { (eval _1.capitalize)&.commands&.keys }.flatten.include? name
  else
    true
  end
end

module Discordrb::Commands
  class CommandBot
    alias_method :execute!, :execute_command
    # Allow output from commands to exceed 2000 chars
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
              Discordrb.split_message(result).each do |chunk|
                event.respond chunk
              end
            end
          end
        rescue => e
          log_exception(e)
        ensure
          @event_threads.delete(t)
        end
      end
    end

    # Check server modules on command execution
    def execute_command(name, event, arguments, chained = false, check_permissions = true)
      return unless can_run(name, event)
      execute!(name, event, arguments, chained, check_permissions)
    end
  end
end
