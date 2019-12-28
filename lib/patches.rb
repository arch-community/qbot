# Allow output from commands to exceed 2000 chars
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
  end
end
