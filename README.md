
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

## Invite qbot to your own server

[Click this link](https://discord.com/oauth2/authorize?client_id=660591224482168842&permissions=339078224&scope=bot) to invite qbot to your own server.

## Running your own instance of qbot

### Set up the environment

#### With Nix

Clone this Git repository and enter its directory.

Run `nix-build ./shell.nix`. The resulting executable is at `result/bin/qbot`.

#### Otherwise

Install Ruby, at least version 3.0 (higher versions untested). Install bundler.

Clone this Git repository. Enter the directory. Run `bundle install` to set up
the environment.

To start the bot, run `bundle exec qbot`.

### Run the bot

qbot is configured in a YAML file at `config/global.yml`. Copy the example
config to `config/global.yml` and add the correct settings for your instance.

Start the bot.

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
  - The `CommandBot` object is called `QBot.bot`.
- `quit` or `stop` stops the bot.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

[1]: https://discord.gg/3m6dbPR
