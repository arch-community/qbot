# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.2'

gem 'bundler'
gem 'rake'

# Base
gem 'discordrb', github: 'shardlab/discordrb', branch: 'main'
# dirty hack to fix bundix problems
gem 'discordrb-webhooks',
    github: 'anna328p/discordrb',
    branch: 'main'

gem 'rbnacl'

gem 'i18n', require: %w[i18n i18n/backend/fallbacks]

# Config
gem 'jsi'

# Help
gem 'word_wrap', require: %w[word_wrap word_wrap/core_ext]

# CLI
gem 'paint'
gem 'reline'

# DB
gem 'activerecord', require: 'active_record'
gem 'rails-pattern_matching'
gem 'sqlite3'

# Jobs
gem 'activejob', require: 'active_job'
gem 'delayed_job_active_record'
gem 'rufus-scheduler'

# Arch
gem 'mediawiki_api'
gem 'narray'
gem 'rss'

# TODO: rustc broken
gem 'tantiny', github: 'anna328p/tantiny',
  ref: '0efa1bf191041fd1d2b392eb4e840f3998d102fa' # branch: 'main'

# figlet
gem 'ruby_figlet'

# xkcd
gem 'open_uri_redirections'

# bottom
gem 'bottom'

# tio
gem 'kramdown', require: %w[kramdown kramdown/document]
gem 'kramdown-parser-gfm', require: 'kramdown/parser/gfm'
gem 'nokogiri'

# image generation
gem 'rails-html-sanitizer'
gem 'rmagick'

# pluralkit
gem 'pluralkit-api', '>= 1.0.1'

group :development do
  # linting
  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false

  # lsp
  gem 'ruby-lsp', require: false
  gem 'solargraph', require: false
  gem 'steep', require: false
  gem 'typeprof', require: false
  gem 'yard', require: false

  # visualization
  gem 'ruby-graphviz'
  gem 'tty-progressbar'

  # analysis
  gem 'parser'
  gem 'unparser'
end

# Colors
gem 'numo-narray'
