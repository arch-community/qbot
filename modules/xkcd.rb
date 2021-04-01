# frozen_string_literal: true

# XKCD comic fetching
module Xkcd
  extend Discordrb::Commands::CommandContainer
  
  def self.xkcd_embed(comic_info)
    embed do |m|
      m.title = "xkcd: #{comic_info[:safe_title]}"
      m.url = XKCD.comic_url(comic_info)
      m.image = { url: comic_info[:img] }
      m.footer = { text: comic_info[:alt] }
    end
  end

  command :xkcd, {
    help_available: true,
    usage: '.xkcd',
    min_args: 0
  } do |event, *args|
    if args[0]&.to_i
      num = args.shift.to_i
      xkcd_embed(XKCD.get_info num)
    elsif args[0]
      # Searching not implemented yet
      embed t('nyi')
    else
      xkcd_embed(XKCD.random_info)
    end
  end
end
