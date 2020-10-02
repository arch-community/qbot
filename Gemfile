source 'https://rubygems.org'

ruby '~> 2.7'

group :default do
  # Base
  # dirty hack to fix bundix problems
  gem 'discordrb-webhooks', github: 'anna328p/discordrb', branch: 'next', ref: '4eadc9296dabf08b89a29e8c0b177664c48c6f88'
  # fix websockets not connecting
  gem 'discordrb', github: 'swarley/discordrb', branch: 'next'
  gem 'rbnacl'

  # Config
  gem 'hashugar'

  # Help
  gem 'word_wrap', require: [ 'word_wrap', 'word_wrap/core_ext' ]

  # CLI
  gem 'reline'
  gem 'irb'
  gem 'paint'

  # DB
  gem 'activerecord', require: 'active_record'
  gem 'sqlite3'
  gem 'activerecord-oracle_enhanced-adapter'
  gem 'ruby-oci8'

  # Logging
  gem 'log4r-color'

  # Arch
  gem 'mediawiki_api'
  gem 'rss'
  gem 'tf-idf-similarity'
  gem 'narray'

  # Music
  gem 'youtube-dl.rb', github: 'gkaklas/youtube-dl.rb', branch: 'terrapin-migration'
  gem 'google-api-client', require: ['google/apis', 'google/apis/youtube_v3', 'googleauth', 'googleauth/stores/file_token_store']
  gem 'soundcloud'

  # figlet
  gem 'ruby_figlet'
end

group :test do
  gem 'rubocop'
end
