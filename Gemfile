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
      ref: '4de9fa6b1853ca3fb7ba321a86712b39b9716c87'
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

  # pluralkit
  gem 'pluralkit-api', '>= 1.0.1'
end

group :default, :development do
  # linting
  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false

  # visualization
  gem 'bundle-viz'
  gem 'ruby-graphviz'
end
# rubocop: enable Metrics/BlockLength
