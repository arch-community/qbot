# frozen_string_literal: true

require 'net/http'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'zlib'

##
# Try It Online API interface
module TIO
  API_BASE = 'https://tio.run'

  def self.run_endpoint
    @run_endpoint ||= URI.parse(
      API_BASE +
        Nokogiri::HTML
          .parse(URI.parse(API_BASE).open)
          .xpath('//head/script[2]/@src')[0]
    ).open.readlines.grep(/^var runURL/)[0][14..-4]
  end

  def self.gzdeflate(str) =
    Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(str, Zlib::FINISH)

  def self.gzinflate(str) = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(str)

  def self.languages =
    JSON.parse(URI.parse("#{API_BASE}/languages.json").open.read)

  def self.languages_by_category(category) =
    languages.filter { |_, v| v['categories'].include? category.to_s }

  def self.file(name, body) = "F#{name}\0#{body.size}\0#{body}"

  def self.var(name, args) =
    "V#{name}\0#{args.size}\0#{args.map { |a| "#{a}\0" }.join}"

  def self.make_req(language, code, flags, input, arguments)
    val = var('lang', [language]) + var('args', arguments)

    if flags
      val += var('TIO_OPTIONS', flags) unless language.start_with? 'java-'
      val += var('TIO_CFLAGS', flags)
    end

    val += file('.code.tio', code)
    val += file('.input.tio', input) if input
    val += 'R'

    gzdeflate(val)
  end

  def self.settings = '/'

  def self.new_token =
    Random.new.bytes(16).unpack('C16').map { format '%02x', _1 }.join

  def self.post_req(uri, data)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request.body = data

    https.request(request)
  end

  def self.run(language, code, flags = nil, input = nil, arguments = [])
    req_body = make_req(language, code, flags, input, arguments)

    uri = URI("#{API_BASE}#{run_endpoint}#{settings}#{new_token}")
    post_res = post_req(uri, req_body)

    res = gzinflate(post_res.body[10..])
    res.split(res[0..15])[1..].map(&:chomp)
  end
end
