# Contributing

## Development

qbot uses [Conventional Commits]. Make sure that your commit messages follow
the spec.

Code structure:

- `qbot` is the main executable that loads the rest of the bot.
- Each module in `modules/*.rb` contains support functions and bot commands.
- `lib` contains code used by multiple modules as well as helper methods.

### Adding modules

Make sure you have done the following:

- All user-facing strings must go through `t` and have entries in at least the
  English translation file (`lib/locales/en.yml`).
- rubocop must return no offenses. Try to avoid disabling cops.
- Do not hard-code any names, IDs, or similar. If your module has global
  configuration, add it to the config file. If it has per-server configuration,
  add it to the JSON column in ServerConfig.
- If you are adding a new DB table, write a schema migration matching the
  format of the existing migrations.
- If you use nix and touch the Gemfile, source `scripts/binst` inside the bot's
  nix-shell environment. This updates `gemset.nix`.

Send a pull request to this git repo. Make sure your code works and that your
commits have meaningful names.

### Translating the bot

Copy the file `lib/locales/en.yml` to your new locale. Change the language code
at the top. Translate all of the strings. Send a pull request.

Your commit should be named something like "i18n: added x translation".

[Conventional Commits]: https://www.conventionalcommits.org/en/v1.0.0/
