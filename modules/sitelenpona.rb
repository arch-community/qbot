# frozen_string_literal: true

##
# sitelen pona drawing commands
module Sitelenpona
  extend Discordrb::Commands::CommandContainer

  command :sp, {
    help_available: true,
    usage: '.sp <text>',
    min_args: 1
  } do |event, *args|
    text = Rails::Html::FullSanitizer.new.sanitize(args.join(' '))

    file = ImageStringIO.new(SPGen.draw_text(text))
    event.send_file(file)
  end
end
