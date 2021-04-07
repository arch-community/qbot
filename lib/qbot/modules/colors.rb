# frozen_string_literal: true

require './lib/colorlib'

# Color role assignment
module Colors # rubocop: disable Metrics/ModuleLength, Style/CommentedKeyword
  extend Discordrb::Commands::CommandContainer

  ColorRole = Struct.new(:idx, :role, :id)

  def self.hex_color?(name)
    name.match?(/^#?[[:xdigit:]]{6}$/)
  end

  def self.color_role?(role, cfg)
    role.name.end_with?('[c]') ||
      (cfg.options['bare-colors'] && hex_color?(role.name))
  end

  def self.auto_color_roles(event)
    cfg = ServerConfig[event.server.id]
    event.server.roles.filter { color_role?(_1, cfg) }.sort_by(&:position).reverse
  end

  def self.indexify(ary)
    ary.each.with_index { |cr, idx| cr.idx = idx }
  end

  def self.get_colors(event)
    bot_roles = auto_color_roles(event)
    default = bot_roles.map { ColorRole.new(nil, _1, _1.id) }

    extra_conf = ExtraColorRole.where(server_id: event.server.id).map(&:role_id) || []
    extra = extra_conf.map { ColorRole.new(nil, event.server.role(_1), _1) }

    colors = indexify(default + extra)

    [colors, default, extra]
  end

  def self.assign_role(event, role_list, role, name)
    if event.author.roles.include? role
      embed t('colors.assign-role.already-have', name)
    else
      event.author.roles -= role_list
      event.author.add_role role
      embed t('colors.assign-role.success', name, role.name)
    end
  end

  # rubocop: disable Naming/MethodParameterName
  def self.color_ring(l, size, num)
    angle = 2 * Math::PI / num

    (0...num).map do
      this_angle = angle * _1
      a = size * Math.cos(this_angle)
      b = size * Math.sin(this_angle)

      ColorLib.lab_to_hex [l, a, b]
    end
  end
  # rubocop: enable Naming/MethodParameterName

  command :color, {
    aliases: [:c],
    help_available: true,
    usage: '.c <color>',
    min_args: 1
  } do |event, *args|
    colors, = Colors.get_colors(event)

    req = args.join(' ')

    requested_color = nil

    begin
      # Find color by index
      idx = Integer(req)
      requested_color = colors.find { _1.idx == idx }
    rescue ArgumentError
      # Find color by name
      requested_color = colors.find { _1.role.name.downcase.start_with? req.downcase }
    end

    # Role for the requested color
    rc = requested_color&.role
    unless rc
      embed t('colors.color.not-found')
      return
    end

    Colors.assign_role(event, colors.map(&:role), rc, t('colors.color.role-type-name'))
  end

  command :closestcolor, {
    aliases: [:cc],
    help_available: true,
    usage: '.cc <color>',
    min_args: 1,
    max_args: 1
  } do |event, color|
    colors, = Colors.get_colors(event)

    labs = colors.sort_by(&:idx).map { ColorLib.hex_to_lab _1.role.color.hex.rjust(6, '0') }
    compare = ColorLib.hex_to_lab(color)

    de = labs.map { ColorLib.cie76(compare, _1) }
    min = de.each.with_index.min_by { |val, _idx| val }

    color = colors.find { _1.idx == min[1] }

    embed t('colors.closest.found',
            "##{color.role.color.hex.rjust(6, '0')}")

    Colors.assign_role(event, colors.map(&:role), color.role, t('colors.color.role-type-name'))
  end

  command :listcolors, {
    aliases: [:lc],
    help_available: true,
    usage: '.lc',
    min_args: 0,
    max_args: 0
  } do |event, *_args|
    colors, = Colors.get_colors(event)

    # Formatted list of the colors
    list = colors.sort_by(&:idx).map do |c|
      idx = c.idx.to_s.rjust(2)
      r = c.role
      "#{idx}: ##{r.color.hex.rjust(6, '0')} #{r.name}"
    end

    embed do |m|
      m.title = t 'colors.list.title'
      m.description = "```#{list.join "\n"}```"
    end
  end

  command :createcolorroles, {
    aliases: [:ccr],
    help_available: false,
    usage: '.createcolorroles <lightness> <spread> <count>',
    min_args: 3,
    max_args: 3
  } do |event, *args|
    unless event.author.permission?(:administrator)
      embed t(:no_perms)
      return
    end

    auto_color_roles(event).each do
      event.respond t('colors.ccr.deleting', _1.name)
      _1.delete
    end

    l = args[0].to_f
    size = args[1].to_f
    num = args[2].to_i

    colors = Colors.color_ring(l, size, num)

    colors.each.with_index do |hex, idx|
      event.server.create_role(
        name: "color#{idx} [c]",
        colour: Discordrb::ColourRGB.new(hex),
        permissions: 0,
        reason: 'Generating color roles'
      )
      event.respond t('colors.ccr.created', "color#{idx}", "##{hex}")
    end

    embed t('colors.ccr.success', colors.size)
  end

  command :randcolors, {
    aliases: [:rc],
    help_available: false,
    usage: '.rc',
    min_args: 0,
    max_args: 0
  } do |event|
    unless event.author.permission?(:administrator)
      embed t(:no_perms)
      return
    end

    users = event.server.members
    colors, default, = Colors.get_colors(event)

    counter = 0
    users.filter { (_1.roles & colors.map(&:role)).empty? }.each do |u|
      u.roles += [default.sample.role]
      counter += 1
    end

    embed t('colors.rc.success', counter)
  end
end

QBot.bot.member_join do |event|
  _, default, = Colors.get_colors(event)

  event.user.add_role(default.sample['role'])
end
