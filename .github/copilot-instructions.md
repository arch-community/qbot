# GitHub Copilot Instructions for qbot

## Project Overview

qbot is a Discord bot written in Ruby for the unofficial Arch Linux community. It's a modular bot that manages support channels, provides Arch Linux resources, and includes various utility features.

## Architecture

- **Main executable**: `qbot` - Loads and initializes the bot
- **Modules**: `modules/*.rb` - Each module contains bot commands and support functions
- **Library code**: `lib/qbot/*.rb` - Shared helper methods and core functionality
- **Database**: SQLite with ActiveRecord ORM
- **Framework**: discordrb for Discord integration
- **Configuration**: YAML files in `config/` directory
- **Localization**: YAML files in `share/locales/` directory

## Coding Standards

### General Ruby Conventions

- **Always** include `# frozen_string_literal: true` at the top of every Ruby file
- Follow the configured RuboCop rules in `.rubocop.yml`
- Maximum line length: 80 characters
- Use semantic block delimiters (braces for functional, do/end for procedural)
- Prefer consistent indentation for arrays and method arguments

### Module Development

- Each module extends `Discordrb::Commands::CommandContainer`
- Commands use the `command :name, { options... } do |event, *args|` pattern
- Use `ServerConfig.extend_schema` to add per-server configuration options
- Never hard-code names, IDs, or similar values
- Module-level documentation should use YARD-style comments (`##`)

### Code Style

- Use modern Ruby syntax (Ruby 3.2+)
- Prefer pattern matching with `rails-pattern_matching` where appropriate
- Use numbered block parameters (`_1`, `_2`) when appropriate
  - Example: `@options.to_h { |e| [e.nickname || e.typeface, e] }`
- Inline access modifiers: `private def method_name`
- Avoid parallel assignment
- Use single-line method definitions with `=` for simple one-liners
  - Example: `def self.hex_code?(string) = string.match?(/^#?[[:xdigit:]]{6}$/)`
- Use forwarding arguments `(...)` to pass all arguments to super or another method

## Internationalization (i18n)

- **All** user-facing strings must go through the `t()` helper method
- Add translation keys to `share/locales/en.yml` at minimum
- Translation files use nested YAML structure
- Available locales: `:en`, `:tok`, `:en_kawaii`, `:de`
- Use descriptive keys: `module.command.message-type`
- The `embed` helper creates Discord embeds for bot responses

## Database

- Use ActiveRecord models in `lib/qbot/db/models/`
- Define schemas and migrations in `lib/qbot/db/schema/`
- Tables include: `ServerConfig`, `ColorRole`, `Query`, `Snippet`, `UserConfig`, etc.
- Database initialization: run `Database.define_schema` in IRB console
- Use concerns in `lib/qbot/db/concerns/` for shared model behavior
- Extend `ServerConfig` schema with `ServerConfig.extend_schema do ... end`

## Testing and Quality Assurance

### Linting

- Run RuboCop: `bundle exec rubocop --parallel`
- RuboCop must return no offenses before submitting PRs
- Try to avoid disabling cops; fix the underlying issue instead

### Commit Messages

- Use [Conventional Commits](https://www.conventionalcommits.org/) format
- Examples:
  - `feat: add new command for querying packages`
  - `fix: correct color role assignment logic`
  - `i18n: added German translation`
  - `docs: update module documentation`

### Markdown Linting

- Markdown files are linted in CI
- Follow `.markdownlintrc` configuration

## Development Workflow

### Setting Up Development Environment

**With Nix (preferred):**
```bash
nix-shell
# or
nix develop
```

**Without Nix:**
```bash
bundle install
```

### Running the Bot

```bash
bundle exec qbot
```

### Bot CLI Commands

- `rs` or `restart` - Restart the bot
- `rc` or `reload-config` - Reload configuration
- `lm` or `load-module` - Load or reload a module
- `irb` - Open REPL in bot context
- `quit` or `stop` - Stop the bot

### Configuration

- Copy example config to `config/global.yml`
- Configure Discord bot token and other settings
- Per-server configuration stored in database

## Adding New Features

### Creating a New Module

1. Create `modules/modulename.rb`
2. Define the module extending `Discordrb::Commands::CommandContainer`
3. Add commands using the `command` DSL
4. Add configuration options with `ServerConfig.extend_schema`
5. Add all user-facing strings to translation files
6. Add command descriptions to `share/locales/en.yml` under `descriptions:`

### Adding Database Tables

1. Create the model in `lib/qbot/db/models/`
2. Define the schema in `lib/qbot/db/schema/`
3. Write migration matching existing migration format
4. Run `Database.define_schema` to apply

### Adding Dependencies

- Add gems to `Gemfile`
- Run `bundle install`
- If using Nix: source `scripts/binst` in nix-shell to update `gemset.nix`

## Common Patterns

### Command Definition

```ruby
command :commandname, {
  aliases: [:alias],
  help_available: true,
  usage: '.command <arg>',
  min_args: 1,
  max_args: 2,
  permission_level: 1
} do |event, *args|
  # Command implementation
  embed t('module.command.response')
end
```

### Embedding Responses

```ruby
embed t('translation.key', variable: value)
```

### Server Configuration

```ruby
ServerConfig.extend_schema do
  option :config_name, TBoolean.new, default: false
  option :other_option, TEnum.new(%w[option1 option2]), default: 'option1'
end
```

### Accessing Configuration

```ruby
config = ServerConfig.for(event.server)
config.config_name  # Access configuration value
```

## Security Considerations

- Never commit secrets or tokens to the repository
- Sanitize user input before using in commands
- Use `Rails::Html::FullSanitizer.new.sanitize(content)` for HTML content (gem: `rails-html-sanitizer`)
  - This is used even though the bot uses discordrb, as some modules process HTML (e.g., wiki content)
- Validate and escape user-provided data in database queries
- Use parameterized queries through ActiveRecord
- Be cautious with user-provided URLs and external content

## File Organization

- **Main bot files**: `lib/qbot/*.rb`
- **Models**: `lib/qbot/db/models/*.rb`
- **Schema**: `lib/qbot/db/schema/*.rb`
- **Modules**: `modules/*.rb`
- **Module subdirectories**: `modules/modulename/*.rb` for module-specific code
- **Translations**: `share/locales/*.yml`
- **Configuration**: `config/*.yml`
- **Scripts**: `scripts/*`

## Nix Integration

This project is a Nix flake with:
- `nixosModule` output for NixOS integration
- Overlay for package availability
- Development shell with all dependencies
- Option `services.qbot` for system-wide configuration

## Discordrb API

- Use `event.author` for the user who invoked the command
- Use `event.server` for the current server
- Use `event.channel` for the current channel
- Member roles: `member.role?(role)`, `member.modify_roles(add, remove, reason)`
- Respond with embeds: `embed { |e| e.description = text }`

## Style Preferences

- Prefer clarity over cleverness
- Document complex logic with comments
- Keep modules focused and single-purpose
- Minimize external dependencies where possible
- Follow existing patterns in the codebase
