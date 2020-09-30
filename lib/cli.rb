module QBot
   def QBot::run_cli
      while buf = Readline.readline('% ', true)
        s = buf.chomp

        if s.start_with? 'quit', 'stop'
          $bot.stop
          exit

        elsif s.start_with? 'reload'
          load_config

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
