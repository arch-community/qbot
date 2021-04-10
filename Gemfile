# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.0'

# rubocop: disable Metrics/BlockLength
group :default do
  # Base
  gem 'discordrb', github: 'shardlab/discordrb', branch: 'main'
  # dirty hack to fix bundix problems
  gem 'discordrb-webhooks',
      github: 'anna328p/discordrb',
      branch: 'main',
      ref: '9ccbda50c00f47d4c3a672c990001c6a49d2982e'
  gem 'rbnacl'

  gem 'i18n',
      require: [
        'i18n',
        'i18n/backend/fallbacks'
      ]

  # Config
  gem 'hashugar'

  # Help
  gem 'word_wrap',
      require: ['word_wrap', 'word_wrap/core_ext']

  # CLI
  gem 'irb'
  gem 'paint'
  gem 'reline'

  # DB
  gem 'activerecord', require: 'active_record'
  gem 'sqlite3'

  # Logging
  gem 'log4r-color'

  # Arch
  gem 'mediawiki_api'
  gem 'narray'
  gem 'rss'
  gem 'tf-idf-similarity'

  # Music
  gem 'google-api-client',
      require: [
        'google/apis',
        'google/apis/youtube_v3',
        'googleauth',
        'googleauth/stores/file_token_store'
      ]

  gem 'soundcloud'

  gem 'youtube-dl.rb',
      github: 'AllanKlaus/youtube-dl.rb',
      branch: 'update-youtube-dl-2020-09-20'

  # figlet
  gem 'ruby_figlet'

  # xkcd
  gem 'open_uri_redirections'

  # bottom
  gem 'bottom'

  # tio
  gem 'kramdown', require: ['kramdown', 'kramdown/document']
  gem 'kramdown-parser-gfm', require: 'kramdown/parser/gfm'
  gem 'nokogiri'

  # image generation
  gem 'rails-html-sanitizer'
  gem 'rmagick'
end

group :default, :development do
  # linting
  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false
end
# rubocop: enable Metrics/BlockLength
