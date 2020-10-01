module QBot
   def QBot::run_cli
      while buf = Readline.readline('% ', true)
         cmd = buf.chomp.split
         s = cmd.shift

         if s.starts_with? 'quit', 'stop'
            $bot.stop
            exit

         elsif s.start_with? 'rc', 'reload-config'
            load_config

         elsif s.starts_with? 'rm', 'reload-module'
            Modules.load_module cmd.shift

         elsif s.start_with? 'rs', 'restart'
            $bot.stop
            exec 'ruby', $PROGRAM_NAME

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
