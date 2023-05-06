# frozen_string_literal: true

##
# Enum class for sitelen pona fonts
class TSPFontSelect < Configurable::OptionTypes::TEnum
  # rubocop: disable Lint/MissingSuper
  def initialize
    @options = SPGen.font_metadata
  end
  # rubocop: enable Lint/MissingSuper
  
  def find_by_abbrev(...)
    @options_hash ||= @options.to_h { |e| [e.nickname || e.typeface, e] }
    @abbrev ||= @options_hash.keys.abbrev

    @options_hash[super].typeface
  end

  def find_by_index(...)
    super.typeface
  end

  def self.get_metadata(typeface)
    SPGen.font_metadata.find { _1.typeface == typeface }
  end

  def format_value(value, ...)
    meta = self.class.get_metadata(value)
    name = meta.nickname || meta.typeface

    super(name, ...)
  end

  def describe_validation
    super options.map(&:typeface)
  end
end

UserConfig.extend_schema do
  group :sitelenpona do
    defaults = SPGen::DrawOptions.new

    option :fg_color, TString.new, default: defaults.fg_color
    option :bg_color, TString.new, default: defaults.bg_color

    option :fontsize,
           TInteger.new(min: 1, max: 128), default: defaults.fontsize

    option :fontface, TSPFontSelect.new, default: defaults.fontface

    option :glyphs, TString.new
  end
end

##
# sitelen pona drawing commands
module Sitelenpona
  extend Discordrb::Commands::CommandContainer

  def self.draw_options(user)
    cfg = UserConfig.for(user)

    symbols = %i[fontface fontsize bg_color fg_color]

    keywords = symbols.to_h { [_1, cfg[:sitelenpona, _1]] }
    SPGen::DrawOptions.new(**keywords)
  end

  def self.name_as_glyphs(member, options)
    glyphs = UserConfig.for(member)[:sitelenpona, :glyphs]

    return "[#{member.display_name}]" unless glyphs

    case options.glyph_style
    when :cartouche then "[_#{glyphs.split.join('_')}]"
    when :brackets then "[#{glyphs}]"
    else glyphs
    end
  end

  def self.replace_mentions(input, mentioned_members, options)
    mentioned_members.reduce(input) { |text, member|
      text.gsub(member.mention, name_as_glyphs(member, options))
    }
  end

  def self.process_text(input, mentioned_members, options)
    res = replace_mentions(input, mentioned_members, options)

    Rails::Html::FullSanitizer.new.sanitize(res)
  end

  def self.get_sp_params(event)
    input = after_nth_word(1, event.message.text)

    options = draw_options(event.author)
    members = event.message.mentions.map { _1.on(event.server.id) }

    text = process_text(input, members, options)
    [text, options]
  end

  command :sp, {
    help_available: true,
    usage: '.sp <text>',
    min_args: 1
  } do |event, _|
    text, options = get_sp_params(event)

    file = NamedStringIO.new(
      SPGen.draw_text(text, options),
      path: "#{event.author.id}.png"
    )

    event.send_file(file)
  end

  command :sppreview, {
    help_available: true,
    usage: '.sppreview <text>',
    min_args: 1
  } do |event, _|
    text, options = get_sp_params(event)

    SPGen.font_metadata.each do |font|
      options.font_face = font.typeface

      filename = "#{event.author.id}.png"
      file = NamedStringIO.new(
        SPGen.draw_text(text, options),
        path: filename
      )

      event.send_file(file)
    end

    nil
  end
end
