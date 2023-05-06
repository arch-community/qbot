# frozen_string_literal: true

##
# sitelen pona image generation
module SPGen
  include Magick

  DrawOptions = Struct.new(
    'DrawOptions',
    :fontface,
    :fontsize,
    :bg_color,
    :fg_color,
    :width,
    :border,
    keyword_init: true
  ) do
    def initialize(...)
      super
      self.fontface ||= 'linja suwi'
      self.fontsize ||= 32
      self.bg_color ||= 'white'
      self.fg_color ||= 'black'
      self.width    ||= 500
      self.border   ||= 5
    end

    def glyph_style
      SPGen.metadata_for(self.fontface).glyph_style
    end
  end

  def self.generate_image(markup, options)
    options => { width:, border:, bg_color: }

    images = Image.read("pango:#{markup}") { |img|
      img.define('pango', 'wrap', 'word-char')
      img.background_color = bg_color
      img.size = "#{width - (2 * border)}x"
    }

    output = images.first
    output.trim!
    output.border!(border, border, bg_color)
  end

  def self.gen_markup(text, options)
    options => { fontface: face, fontsize: size, fg_color: }

    <<~PANGO
      <span face="#{face}" size="#{size}pt" foreground="#{fg_color}">
        #{text}
      </span>
    PANGO
  end

  def self.draw_text(text, options = nil, **kwargs)
    options ||= DrawOptions.new(**kwargs)

    markup = gen_markup(text, options)
    image = generate_image(markup, options)

    blob_png = image.to_blob { _1.format = 'png' }
    image.destroy!

    blob_png
  end

  def self.load_metadata_file
    path = File.join(__dir__, *%w[.. .. share fonts tokipona metadata.yml])
    YAML.load_file(path, symbolize_names: true)
  end

  @font_metadata = nil
  @font_entry = nil
  def self.font_metadata
    unless @font_metadata
      yaml = load_metadata_file

      keys = yaml.dig(:schema, :fonts).map(&:to_sym)
      @font_entry = Struct.new('FontEntry', *keys, keyword_init: true)

      @font_metadata = yaml[:fonts].map { @font_entry.new(**_1) }
    end

    @font_metadata
  end

  def self.metadata_for(typeface)
    font_metadata.find { _1.typeface == typeface }
  end
end
