# frozen_string_literal: true

##
# sitelen pona drawing commands
module Sitelenpona
  extend Discordrb::Commands::CommandContainer

  def self.format_opts(cfg)
    {
      fg_color: cfg[:fgcolor],
      bg_color: cfg[:bgcolor],
      font: cfg[:fontface],
      size: cfg[:fontsize],
      name: cfg[:name],
      glyphs: cfg[:glyphs]
    }.compact { |_, v| v }
  end

  def self.get_opts(author)
    uc = UserConfig[author.id]

    if (c = uc.contents['sitelenpona']&.symbolize_keys)
      format_opts(c)
    else
      {}
    end
  end

  command :sp, {
    help_available: true,
    usage: '.sp <text>',
    min_args: 1
  } do |event, _|
    msg = event.message
    text = strip_command(msg.text, event.command.name)

    sanitized = Rails::Html::FullSanitizer.new.sanitize(text)

    filename = "#{event.author.id}.png"
    file = ImageStringIO.new(
      SPGen.draw_text(sanitized, **get_opts(event.author)),
      path: filename
    )

    event.send_file(file)
  end
end
