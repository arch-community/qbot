# Copilot Instructions for qbot

## Overview

qbot is a Discord bot for the unofficial Arch Linux community, written in Ruby.
It uses the `discordrb` library for Discord interaction and ActiveRecord with
SQLite for persistence. The bot is modular — each feature (Arch wiki search,
color roles, snippets, etc.) lives in its own module file.

## Build and Validation

### Prerequisites

- Ruby ~> 3.2 (see `Gemfile`)
- Bundler

### Bootstrap

```sh
bundle install
```

If using Nix, enter the dev shell first (`nix develop` or `nix-shell shell.nix`)
and source `scripts/binst` after touching the Gemfile to regenerate `gemset.nix`.

### Linting (always run before submitting)

```sh
bundle exec rubocop --parallel
```

RuboCop must return **zero offenses**. Configuration is in `.rubocop.yml`.
Key style rules: 80-char line limit, `semantic` block delimiters,
`inline` access modifiers, `with_fixed_indentation` argument alignment.

### Markdown linting

Markdown files are linted in CI with `markdownlint`. Config is in
`.markdownlintrc` (MD041/first-line-heading is disabled).

### Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
format. CI enforces this via `commitlint`.

### Tests

There is currently no automated test suite. Validate changes by running
`bundle exec rubocop --parallel` and confirming no new offenses.

### Running the bot locally

```sh
cp config/global.yml.example config/global.yml
# Edit config/global.yml with valid Discord bot token and client_id
bundle exec ruby qbot
```

## CI Workflows (`.github/workflows/`)

| File       | Purpose                            |
|------------|------------------------------------|
| `lint.yml` | RuboCop, commitlint, markdownlint  |
| `nix.yml`  | Nix build + smoke test via Cachix  |

## Project Layout

```text
qbot                  # Main executable (entry point: QBot.run!)
lib/
  qbot.rb             # Requires all library files
  qbot/
    init.rb            # Bot initialization and run loop
    modules.rb         # Module loader
    cli.rb             # Interactive bot CLI
    db.rb              # ActiveRecord setup, model/concern loading
    db/
      schema.rb        # Database schema definition
      migrate/         # ActiveRecord migrations
      models/          # ActiveRecord model classes
      concerns/        # Shared model concerns
    db_config.rb       # Database connection config
    global_config.rb   # YAML config loader (JSI-based)
    i18n.rb            # Translation helper (t function)
    helpers.rb         # Shared helper methods for modules
    hooks.rb           # Discord event hooks
    options.rb         # CLI option parsing
    version.rb         # Version string
    colorlib.rb        # Color manipulation library
    ...                # Feature-specific libraries (xkcd, arch_*, tio, etc.)
modules/
  *.rb                 # Bot command modules (one per feature)
  admin/               # Admin sub-modules
  colors/              # Color sub-modules
config/
  global.yml.example   # Example configuration file
share/
  locales/             # i18n translation files (en.yml, de.yml, etc.)
  global_config.schema.json  # JSON Schema for config validation
  fonts/               # Font assets
scripts/
  binst                # Nix gemset regeneration helper
  compare_locales.rb   # Locale comparison utility
sig/                   # RBS type signatures
Rakefile               # ActiveRecord database tasks (rake db:migrate, etc.)
```

## Key Conventions

### Ruby files

- Always include `# frozen_string_literal: true` as the first line.
- Avoid disabling RuboCop cops unless absolutely necessary.

### Modules

Each module in `modules/*.rb` follows this pattern:

```ruby
# frozen_string_literal: true

module ModuleName
  extend Discordrb::Commands::CommandContainer

  command :name, { help_available: true, usage: '.name', min_args: 0 } do |event|
    # ...
  end
end
```

Modules are loaded dynamically by `lib/qbot/modules.rb` based on the list
in `config/global.yml`.

### Internationalization

All user-facing strings must use the `t()` helper defined in `lib/qbot/i18n.rb`
and have corresponding entries in `share/locales/en.yml` (and ideally other
locale files).

### Database

- Uses ActiveRecord with SQLite3 by default.
- Schema is defined in `lib/qbot/db/schema.rb`.
- Migrations go in `lib/qbot/db/migrate/` with a date-prefixed filename.
- Models live in `lib/qbot/db/models/`.
- Run migrations via `bundle exec rake db:migrate`.

### Configuration

- Global config is a YAML file at `config/global.yml`.
- Schema is at `share/global_config.schema.json`.
- Per-server config is stored in the database JSON column.
- Never hard-code names, IDs, or similar values — use config instead.

### Design philosophy

Prefer FP influences: immutable data, pure functions, minimal mutable state,
and dependency injection. The project is migrating toward `dry-system` for DI,
`rom-rb` for database access, and modern Discord features (slash commands,
components v2).
