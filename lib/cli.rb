module QBot
   def QBot::run_cli
      while buf = Readline.readline('% ', true)
         cmd = buf.chomp.split
         s = cmd.shift

         # Stop the bot
         if s.starts_with? 'quit', 'stop'
            $bot.stop
            exit

         # Reload the config from the default location
         elsif s.start_with? 'rc', 'reload-config'
            load_config

         # Load or reload a module
         elsif s.starts_with? 'lm', 'load-module'
            name = cmd.shift

            begin
               Modules.load_module name
            rescue LoadError
               puts "Module not found: #{name}"
            end

         # Restart the bot
         elsif s.start_with? 'rs', 'restart'
            $bot.stop
            exec 'ruby', $PROGRAM_NAME

         # Spin up an IRB session in the context of the bot
         elsif s.start_with? 'irb'
            binding.irb

         elsif s == ''
            next

         else
            puts 'Command not found'

         end
      end
   end
end
