
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

- `bot.rb` initializes the bot and loads modules from a list.
- Each module in `modules/*.rb` contains support functions and bot commands.
- The bot is configured in a file called `config.yml`. Copy `config.yml.example`
  to `config.yml` and add the correct settings for your instance or server.

Modules:
- `help` provides a help command that displays information and usage for modules and commands.
- `queries` helps manage support channels by managing a database of support questions.
- `snippets` allows setting and posting configurable text snippets.
- `colors` generates, manages, and assigns color roles.
- `arch` contains commands for searching the Arch wiki, repositories, and AUR.
- `music` is a fully functional music bot that uses youtube-dl to play audio from a URL.
- `figlet` converts text to ASCII art.
- `util` provides utility commands.
- `admin` provides commands for bot administration.

Bot CLI:

- `rs` or `restart` restarts the bot.
- `rc` or `reload-config` reloads the config.
- `lm` or `load-module` loads or reloads a module.
- `irb` opens a REPL in the context of the bot. The `CommandBot` object is called `$bot`.
- `quit` or `stop` stops the bot.

The bot uses an SQLite database to store support queries. On first run, open `irb`
and run `define_schema`.

[1]: https://discord.gg/3m6dbPR
