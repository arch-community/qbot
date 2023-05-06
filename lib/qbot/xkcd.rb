# frozen_string_literal: true

# Code based on github:hemanth/xkcd-gem
# License: AGPLv3

require 'open-uri'
require 'json'
require 'uri'

##
# XKCD query interface
class XKCD
  def self.random_id
    URI.open('https://dynamic.xkcd.com/random/comic/', allow_redirections: :all)
       .base_uri.to_s
       .split('/').last.to_i
  end

  def self.parse_info(io) = JSON.parse(io.read).symbolize_keys

  def self.get_info(id) =
    parse_info(URI.open("https://xkcd.com/#{id}/info.0.json"))

  def self.latest_info = parse_info(URI.open('https://xkcd.com/info.0.json'))

  def self.random_info = get_info(random_id)

  def self.comic_url(info) = "https://xkcd.com/#{info[:num]}"
end
