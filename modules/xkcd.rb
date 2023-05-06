# frozen_string_literal: true

# XKCD comic fetching
module Xkcd
  extend Discordrb::Commands::CommandContainer

  def self.xkcd_embed(info)
    embed do |m|
      m.title = "xkcd: #{info[:safe_title]}"
      m.url = XKCD.comic_url(info)
      m.image = { url: info[:img] }
      m.footer = { text: info[:alt] }
    end
  end

  command :xkcd, {
    help_available: true,
    usage: '.xkcd',
    min_args: 0
  } do |_, *args|
    case args
    in [/^[lL]/, *]
      xkcd_embed(XKCD.latest_info)
    in [arg, *]
      num = parse_int(arg)
      next embed t('nyi') unless num

      xkcd_embed(XKCD.get_info(num))
    else
      xkcd_embed(XKCD.random_info)
    end
  end
end
