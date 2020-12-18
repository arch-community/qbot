# frozen_string_literal: true

require 'xkcd'

# monkey-patch to fix redirects
class XKCD
  def self.comic
    open("https://dynamic.xkcd.com/random/comic/", allow_redirections: :all)
      .base_uri.to_s
  end
end

# XKCD comic fetching
module Xkcd
  extend Discordrb::Commands::CommandContainer

  command :xkcd, {
    help_available: true,
    description: 'Gets an XKCD comic by ID or name',
    usage: '.xkcd',
    min_args: 0
  } do |event, *args|
    log(event)

    if args[0]&.to_i
      num = args.shift.to_i
      event.respond XKCD.get_comic num
    elsif args[0]
      event.respond XKCD.search args.join
    else
      event.respond XKCD.comic
    end
  end
end
