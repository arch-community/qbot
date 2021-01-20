# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 2.7'

# rubocop: disable Metrics/BlockLength
group :default do
  # Base
  gem 'discordrb', github: 'shardlab/discordrb', branch: 'main'
  # dirty hack to fix bundix problems
  # gem 'discordrb-webhooks',
  #     github: 'anna328p/discordrb',
  #     branch: 'main',
  #     ref: '4f5a7f06d653aaa3aabd305495520e154525fcd2'

  gem 'rbnacl'

  # Config
  gem 'hashugar'
  gem 'i18n'

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
      github: 'AllanKlaus/youtube-dl.rb',
      branch: 'update-youtube-dl-2020-09-20'

  # figlet
  gem 'ruby_figlet'

  # xkcd
  gem 'open_uri_redirections'
  gem 'xkcd'

  # preview color roles
  gem 'rmagick'
end

group :default, :development do
  # linting
  gem 'rubocop'
end
# rubocop: enable Metrics/BlockLength
