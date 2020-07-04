def log(event, extra = nil)
  user = event.author
  username = formatted_name(event.author)

  chan_id = $config['servers'][event.server.id]['log-channel']

  Log4r::Logger['bot'].info("command execution by #{username}: #{event.message}" + (extra ? "; #{extra}" : ''))

  if chan_id
    event.bot.channel(chan_id).send_embed do |m|
      m.author = { name: username, icon_url: user.avatar_url }
      m.title = 'Command execution'
      m.fields = [
        { name: "Command", value: "#{event.message}" },
        { name: "User ID", value: user.id, inline: true },
        extra ? { name: "Information", value: extra } : nil
      ].compact
      m.timestamp = Time.now
    end
  end
end

def formatted_name(u)
  "#{u.name}##{u.discriminator}"
end

module Util
  extend Discordrb::Commands::CommandContainer

  command :echo, {
    help_available: true,
    description: 'Echoes a string',
    usage: '.echo <string>',
    min_args: 1
  } do |event, *args|
    log(event)
    args.join(' ').gsub('@', "\\@\u200D")
  end

  command :mygit, {
    help_available: false
  } do |event|
    "https://github.com/dkudriavtsev/qbot"
  end
end
