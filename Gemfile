source 'https://rubygems.org'

ruby '~> 2.7'

group :default do
  # Base
  # dirty hack to fix bundix problems
  gem 'discordrb-webhooks', git: 'https://github.com/anna328p/discordrb', branch: 'next', ref: '4eadc9296dabf08b89a29e8c0b177664c48c6f88'
  # fix websockets not connecting
  gem 'discordrb', git: 'https://github.com/swarley/discordrb', branch: 'next'
  gem 'rbnacl'

  # Config
  gem 'hashugar'

  # Help
  gem 'word_wrap', require: 'word_wrap/core_ext'

  # CLI
  gem 'reline'
  gem 'irb'

  # DB
  gem 'activerecord', require: 'active_record'
  gem 'sqlite3'

  # Logging
  gem 'log4r'

  # Arch
  gem 'mediawiki_api'
  gem 'rss'
  gem 'tf-idf-similarity'
  gem 'narray'

  # Music
  gem 'youtube-dl.rb'
  gem 'google-api-client', require: ['google/apis', 'google/apis/youtube_v3', 'googleauth', 'googleauth/stores/file_token_store']
  gem 'soundcloud'
end
