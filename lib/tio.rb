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
    @@run_endpoint ||= URI.open(
      API_BASE + Nokogiri::HTML.parse(URI.open(API_BASE)).xpath('//head/script[2]/@src')[0]
    ).readlines.grep(/^var runURL/)[0][14..-4]
  end

  def self.gzdeflate(str) =
    Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(str, Zlib::FINISH)

  def self.gzinflate(str) =
    Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(str)

  def self.languages = JSON.parse(URI.open("#{API_BASE}/languages.json").read)

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

  def self.run(language, code, flags = nil, input = nil, arguments = [])
    req_body = make_req(language, code, flags, input, arguments)

    args = '/' # purpose unknown

    request_count = 0
    begin
      token = Random.new.bytes(16).chars.map { |c| c.ord.to_s(16) }.join
      uri_string = API_BASE + run_endpoint + args + token

      uri = URI(uri_string)
      post_res = Net::HTTP.post(uri, req_body)
      request_count += 1
      post_res.value
    rescue Net::HTTPServerException
      retry if request_count < 5
      raise
    end

    res = gzinflate(post_res.body[10..-1])

    res.split(res[0..15])[1..-1].map(&:chomp)
  end
end
