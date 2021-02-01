
                _/                 _/
        _/_/_/ _/_/_/     _/_/  _/_/_/_/
     _/    _/ _/    _/ _/    _/  _/
    _/    _/ _/    _/ _/    _/  _/
     _/_/_/ _/_/_/     _/_/      _/_/
        _/
       _/

---

qbot is the bot used by the [unofficial Arch Linux community][1] on Discord.
Originally its only function was to manage support channels, but it has evolved
to do much more.

Modules:
- `admin` lets server owners administer and configure the bot.
- `arch` contains commands for searching the Arch wiki, repositories, and AUR.
- `blacklist` can automatically delete messages matching configurable regexes.
- `colors` generates, manages, and assigns color roles.
- `figlet` converts text to ASCII art.
- `help` provides a help command that displays information about commands.
- `music` is a fully functional music bot that uses youtube-dl to play audio
  by URL. (Currently broken)
- `queries` helps manage support channels using a database of support questions.
- `snippets` lets users invoke configurable text snippets.
- `util` provides simple utility commands.
- `xkcd` allows searching and posting XKCD comics.

## Running qbot

### Set up the environment

#### With Nix

Clone this Git repository. cd into the directory and enter a `nix-shell`.

#### Otherwise

Install Ruby, at least version 2.7 (higher versions untested). Install bundler.

Clone this Git repository. Enter the directory. Run `bundle install` to set up
the environment.

### Run the bot

qbot is configured in a YAML file at `config/global.yml`. Copy the example
config to `config/global.yml` and add the correct settings for your instance.

To start the bot, run `bundle exec qbot`.

qbot uses an SQLite database to store per-server configuration and user data.
To initialize the database, let qbot fully start up, then enter `irb` into the
bot CLI to enter the irb console. In this mode, run `Database.define_schema`.
Press Ctrl+D to exit and type `rs` to restart the bot.

### Administration

Bot CLI:

- `rs` or `restart` restarts the bot.
- `rc` or `reload-config` reloads the config.
- `lm` or `load-module` loads or reloads a module.
- `irb` opens a REPL in the context of the bot.
  - The `CommandBot` object is called `bot`.
- `quit` or `stop` stops the bot.

## Development

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

[1]: https://discord.gg/3m6dbPR
