module Admin
  extend Discordrb::Commands::CommandContainer

  command :eval, {
    help_available: false,
    description: 'Evaluates some code. Owner-only.',
    usage: '.eval <code>',
    min_args: 1
  } do |e, *args|
    log(e)

    _ = m = e.message
    a = e.author
    if a.id == $config.owner
      eval args.join(' ')
    else
      "nope"
    end
  end

  command :modules, {
    help_available: true,
    description: 'Lists loaded modules',
    usage: '.modules',
    min_args: 0, max_args: 0
  } do |e|
    e.channel.send_embed do |m|
      m.title = 'Loaded modules'
      m.fields = [
        {
          name: 'Global',
          value: $config.global.modules.join(', '),
        }
      ]
      if $config.servers[e.server.id]&.modules
        m.fields << {
          name: 'Local',
          value: $config.servers[e.server.id].modules.join(', '),
        }
      end
    end
  end
end
