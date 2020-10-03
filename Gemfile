# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 2.7'

# rubocop: disable Metrics/BlockLength
group :default do
  # Base
  gem 'discordrb', github: 'swarley/discordrb', branch: 'next'
  # dirty hack to fix bundix problems
  gem 'discordrb-webhooks',
      github: 'anna328p/discordrb',
      branch: 'next',
      ref: '4eadc9296dabf08b89a29e8c0b177664c48c6f88'
  gem 'rbnacl'

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
  gem 'activerecord-oracle_enhanced-adapter'
  gem 'ruby-oci8'
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
      github: 'gkaklas/youtube-dl.rb',
      branch: 'terrapin-migration'

  # figlet
  gem 'ruby_figlet'

  # linting
  gem 'rubocop'
end
# rubocop: enable Metrics/BlockLength
