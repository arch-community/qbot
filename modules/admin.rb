require './lib/colorlib.rb'

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

  command :createcolorroles, {
    aliases: [ :ccr ],
    help_available: true,
    description: 'Creates color roles',
    usage: '.createcolorroles <lightness> <spread> <count>',
    min_args: 3,
    max_args: 3
  } do |event, *args|
    g = event.server

    if not event.author.permission?(:administrator, event.server)
      return "You do not have the required permissions for this."
    end

    g.roles.filter { _1.name.ends_with? '[c]' }.each do
      event.respond "Deleting existing color role `#{_1.name}`."
      _1.delete
    end

    l = args[0].to_f
    size = args[1].to_f
    num = args[2].to_i

    angle = 2 * Math::PI / num

    colors = (0...num).map do
      this_angle = angle * _1
      a = size * Math.cos(this_angle)
      b = size * Math.sin(this_angle)

      lab_to_hex [l, a, b]
    end

    colors.each.with_index do |hex, idx|
      event.server.create_role(
        name: "color#{idx} [c]",
        colour: Discordrb::ColourRGB.new(hex),
        permissions: 0,
        reason: 'Generating color roles'
      )
      event.respond "Created role `color#{idx}` with color `##{hex}`."
    end
    
    "Created #{colors.size} roles."
  end
end
