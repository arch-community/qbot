# frozen_string_literal: true

require_relative 'lib/qbot/version'

Gem::Specification.new do |s|
  s.name          = 'qbot'
  s.version       = QBot::VERSION
  s.authors       = ['Anna Kudriavtsev']
  s.email         = 'anna328p@gmail.com'

  s.summary       = 'QBot'
  s.description   = 'A Discord bot'
  s.homepage      = 'https://github.com/arch-community/qbot'
  s.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|vendor|db)/}) }
  end

  s.bindir        = 'exe'
  s.executables   = 'qbot'
  s.require_paths = ['lib']

  s.license = 'AGPL-3.0-or-later'
end
