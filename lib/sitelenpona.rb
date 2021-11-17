# frozen_string_literal: true

##
# sitelen pona image generation
module SPGen
  include Magick

  def self.draw_markup(markup, bg_color: 'white', width: 490)
    output = ImageList.new

    # rubocop: disable Style/RedundantSelf
    output << Image.read("pango:#{markup}") do
      self.define('pango', 'wrap', 'word-char')
      self.background_color = bg_color
      self.size = "#{width}x"
    end.first
    # rubocop: enable Style/RedundantSelf

    output.flatten_images
  end

  # rubocop: disable Metrics/ParameterLists
  def self.draw_text(text,
                     font: 'linja suwi',
                     size: 32,
                     bg_color: 'white',
                     fg_color: 'black',
                     width: 500,
                     border: 5)
    markup = <<~MARK
      <span face="#{font}" size="#{size * 4000 / 3}" foreground="#{fg_color}">#{text}</span>
    MARK

    textimg = draw_markup(markup, bg_color: bg_color, width: width - (border * 2))
    out_img = textimg.trim.border(border, border, bg_color)
    textimg.destroy!

    res = out_img.to_blob { self.format = 'png' }
    out_img.destroy!

    res
  end
  # rubocop: enable Metrics/ParameterLists

  @font_metadata = nil
  def self.font_metadata
    @font_metadata ||= YAML.load_file(
      'lib/resources/fonts/tokipona/metadata.yml'
    ).deep_symbolize_keys[:fonts]
  end
end
