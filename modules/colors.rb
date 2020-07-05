def get_colors(event)
  colors_all = $config.servers[event.server.id].roles.colors

  default = colors_all.default
  extra = colors_all.extra

  colors = default + extra

  colors.each { _1['role'] = event.server.role(_1['id']) }

  return colors, default, extra
end

$bot.member_join do |event|
  _, default, _ = get_colors(event)

  event.user.add_role(default.sample['role'])
end

module Colors
  extend Discordrb::Commands::CommandContainer

  command :color, {
    aliases: [ :c ],
    help_available: true,
    description: 'Sets your user color',
    usage: '.c <color>',
    min_args: 1,
  } do |event, *args|
    log(event)

    colors, _ = get_colors(event)

    req = args.join(' ')

    user_colors = event.author.roles & colors.map { _1['role'] }

    requested_color = nil
    if (idx = req.to_i) != 0
      # Find color by index
      requested_color = colors.find { _1['index'] == idx }
    else
      # Find color by name
      requested_color = colors.find { _1['name'].downcase.start_with? req.downcase }
    end

    # Role for the requested color
    rc = requested_color['role'] || (return 'Color not found.')

    if user_colors.include? rc
      'You already have that color.'
    else
      user_colors.each { event.author.remove_role(_1) }
      event.author.add_role rc
      "Your color is now **#{rc.name}**."
    end
  end

  command :listcolors, {
    aliases: [ :lc ],
    help_available: true,
    description: 'Lists colors',
    usage: '.lc',
    min_args: 0,
    max_args: 0
  } do |event, *args|
    log(event)

    colors, _ = get_colors(event)

    # Formatted list of the colors
    list = colors.sort_by { _1['index'] }.map do |c|
      idx = c['index'].to_s.rjust(2)
      r = c['role']
      "#{idx}: ##{r.color.hex} #{r.name}"
    end

    event.channel.send_embed do |m|
      m.title = 'All colors'
      m.description = "```#{list.join ?\n}```"
    end
  end
end
