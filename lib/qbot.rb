# frozen-string-literal: true

require 'bundler'
Bundler.require :default

require 'json'
require 'yaml'
require 'digest'
require 'uri'
require 'open-uri'

def require_libs(libs)
  libs.each { require "qbot/#{_1}" }
end

require_libs %w[
  version
  globals
  options
  patches
  hooks
  db
  i18n
  configuration
  helpers
  xkcd
  breaking_wrap
  modules
  cli
  init
]
