def load_config
  $config = (YAML.load_file 'config.yml' || {}).to_hashugar
  Log4r::Logger['bot'].info 'Loaded configuration'
end

def formatted_name(u)
  "#{u.name}##{u.discriminator}"
end

def prefix(id)
  $config.servers[id]&.prefix || $config.global.prefix || '.'
end

def cmd_prefix(m)
  pfx = prefix(m.channel.server.id)
  m.text.start_with?(pfx) ? m.text[pfx.length..-1] : nil
end

def log(event, extra = nil)
  user = event.author
  username = formatted_name(event.author)

  chan_id = $config.servers[event.server.id]&.log_channel

  Log4r::Logger['bot'].info("command execution by #{username}: #{event.message}#{extra && "; #{extra}"}")

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
