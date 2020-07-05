source 'https://rubygems.org'

ruby '~> 2.7'

group :default do
  # Base
  # dirty hack to fix bundix problems
  gem 'discordrb-webhooks', git: 'https://github.com/dkudriavtsev/discordrb', branch: 'voice_websocket_update', ref: '43895b3ccc2bb12a38f43b3a720ba4aaf6eafe27'
  # fix websockets not connecting
  gem 'discordrb', git: 'https://github.com/swarley/discordrb', branch: 'voice_websocket_update'
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
