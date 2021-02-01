
                _/                 _/
        _/_/_/ _/_/_/     _/_/  _/_/_/_/
     _/    _/ _/    _/ _/    _/  _/
    _/    _/ _/    _/ _/    _/  _/
     _/_/_/ _/_/_/     _/_/      _/_/
        _/
       _/

---

qbot is the Discord bot used by the [unofficial Arch Linux community][1] on Discord.
Originally its only function was to manage support channels, but it has evolved to
do much more.

Code structure:

- `qbot` is the main executable that loads the rest of the bot.
- Each module in `modules/*.rb` contains support functions and bot commands.
- The bot is configured in a YAML file at `config/global.yml`. Copy the example config
  to `config/global.yml` and add the correct settings for your instance.

Modules:
- `admin` lets server owners administer and configure the bot.
- `arch` contains commands for searching the Arch wiki, repositories, and AUR.
- `blacklist` can automatically delete messages matching configurable regexes.
- `colors` generates, manages, and assigns color roles.
- `figlet` converts text to ASCII art.
- `help` provides a help command that displays information about commands.
- `music` is a fully functional music bot that uses youtube-dl to play audio by URL. (Currently broken)
- `queries` helps manage support channels through a database of support questions.
- `snippets` lets users invoke configurable text snippets.
- `util` provides simple utility commands.
- `xkcd` allows searching and posting XKCD comics.

Bot CLI:

- `rs` or `restart` restarts the bot.
- `rc` or `reload-config` reloads the config.
- `lm` or `load-module` loads or reloads a module.
- `irb` opens a REPL in the context of the bot. The `CommandBot` object is called `bot`.
- `quit` or `stop` stops the bot.

The bot uses an SQLite database to store per-server configuration and user data.
To initialize the database, run the bot and let it fully start up, then enter `irb`
into the bot CLI. In the irb console, run `Database.define_schema`. Press Ctrl+D
and type `rs`.

[1]: https://discord.gg/3m6dbPR
