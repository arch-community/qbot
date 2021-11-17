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
      size: cfg[:fontsize]
    }.compact { |_, v| v }
  end

  def self.get_opts(author)
    uc = UserConfig[author.id]

    if (c = uc.options['sitelenpona']&.symbolize_keys)
      format_opts(c)
    else
      {}
    end
  end

  def self.replacement_glyphs(user)
    [UserConfig[user.id].options['sitelenpona']['glyphs'].split, nil]
  rescue StandardError
    [false, user.username.capitalize]
  end

  def self.glyph_style(author)
    fn = UserConfig[author.id].options['sitelenpona']['fontface']
    font = SPGen.font_metadata.find { _1[:typeface] == fn }
    font[:glyph_style]
  rescue StandardError
    :brackets
  end

  def self.name_text(user, style)
    glyphs, fallback = replacement_glyphs(user)

    return "[#{fallback}]" unless glyphs

    case style
    when :cartouche then "[_#{glyphs.join '_'}]"
    when :brackets then "[#{glyphs.join ' '}]"
    when :none then glyphs.join ' '
    else glyphs.join ' '
    end
  end

  def self.replace_all(text, users, style)
    users.each do |user|
      m = user.mention
      text.gsub! m, name_text(user, style)
      text.gsub! m.insert(2, '!'), name_text(user, style)
    end

    text
  end

  def self.safe_text(event)
    msg = event.message
    text = replace_all(
      strip_command(msg.text, event.command.name),
      msg.mentions,
      glyph_style(msg.author)
    )

    Rails::Html::FullSanitizer.new.sanitize(text)
  end

  command :sp, {
    help_available: true,
    usage: '.sp <text>',
    min_args: 1
  } do |event, _|
    text = safe_text(event)

    filename = "#{event.author.id}.png"
    file = ImageStringIO.new(
      SPGen.draw_text(text, **get_opts(event.author)),
      path: filename
    )

    event.send_file(file)
  end

  command :sppreview, {
    help_available: true,
    usage: '.sppreview <text>',
    min_args: 1
  } do |event, _|
    text = safe_text(event)
    opts = get_opts(event.author)

    SPGen.font_metadata.each do |font|
      opts[:font] = font[:typeface]
      filename = "#{event.author.id}.png"
      file = ImageStringIO.new(
        SPGen.draw_text(text, **opts),
        path: filename
      )

      event.send_file(file)
    end

    nil
  end
end
