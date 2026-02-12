# frozen_string_literal: true

module Colors
  ##
  # Check if a string represents a hex color code, '#XXXXXX' or 'XXXXXX'
  def self.hex_code?(string) = string.match?(/^#?[[:xdigit:]]{6}$/)

  ##
  # Assigns a role to a member, ensuring they have only one from a given list.
  def self.assign_color_role(member, new_role)
    all_roles = ColorRole.for(member.server).map(&:role)

    if member.role?(new_role)
      embed QBot::Helpers.t('colors.assign-role.already-have')
    else
      member.modify_roles(new_role, all_roles, 'Change color')
      embed QBot::Helpers.t('colors.assign-role.success', new_role.name)
    end
  end

  command :color, {
    aliases: [:c],
    help_available: true,
    usage: '.c <color>',
    min_args: 1
  } do |event, *args|
    new_role = ColorRole.search(event.server, args.join(' '))
    next embed QBot::Helpers.t('colors.color.not-found') unless new_role

    Colors.assign_color_role(event.author, new_role.role)
  end

  command :closestcolor, {
    aliases: [:cc],
    help_available: true,
    usage: '.cc <color>',
    min_args: 1,
    max_args: 1
  } do |event, target|
    is_valid = Colors.hex_code?(target)
    next embed QBot::Helpers.t('colors.closest.invalid-hex', target) unless is_valid

    closest = ColorRole.find_closest_on(event.server, target)
    embed QBot::Helpers.t('colors.closest.found', closest.hex_code)

    Colors.assign_color_role(event.author, closest.role)
  end

  command :listcolors, {
    aliases: [:lc],
    help_available: true,
    usage: '.lc',
    min_args: 0,
    max_args: 0
  } do |event, *_args|
    entries = ColorRole.for(event.server)

    lines = entries.map.with_index { |r, i| r.to_list_line(i, entries.count) }

    embed do |m|
      m.title = QBot::Helpers.t('colors.list.title')
      m.description = lines.join("\n")
    end
  end

  def self.find_targets(server, roles)
    server.members.reject { _1.roles.intersect? roles }
  end

  def self.randomize_color_roles(server, &)
    roles = ColorRole.for(server).map(&:role)
    targets = find_targets(server, roles)

    m = RCEmbed.new(targets.count, &)

    targets.each_with_index do |target, index|
      target.add_role(roles.sample, 'Randomly assigning color role')
      m.progress = index
    end

    m.finish!
  end

  ##
  # Randomly assign a color role to members who do not have one
  command :randcolors, {
    aliases: [:rc],
    help_available: true,
    usage: '.rc',
    min_args: 0,
    max_args: 0
  } do |event|
    next embed QBot::Helpers.t('no_perms') unless event.author.permission?(:manage_roles)

    randomize_color_roles(event.server) { event.send_embed('', _1) }
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def self.create_color_roles(server, lightness, radius, count, &)
    # Delete all roles detected as auto-generated color roles
    old_roles = ColorRole.for(server, bare: false, extra: false)

    m = CCREmbed.new(old_roles.count, &)

    old_roles.each_with_index do |role, index|
      m.show_role_delete!(role, index + 1)
      role.destroy!
    end

    QBot.bot.init_cache # otherwise the old roles will stay in cache :(

    m.begin_create_stage!(count)

    new_colors = ColorRole.color_ring(lightness, radius, count)

    new_colors.each_with_index do |hex, index|
      role = ColorRole.create_generated(server, hex, index)
      role.move_to_bottom!

      m.show_role_create!(role, index + 1)
    end

    QBot.bot.init_cache # otherwise roles will be seen in reverse order :(

    m.success!
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  command :gencolors, {
    aliases: %i[createcolorroles ccr],
    help_available: true,
    usage: '.gencolors <lightness> <radius> <count>',
    min_args: 3,
    max_args: 3,
    arg_types: [Float, Float, Integer]
  } do |event, l, r, c|
    next embed QBot::Helpers.t('no_perms') unless event.author.permission?(:manage_roles)

    create_color_roles(event.server, l, r, c) { event.send_embed('', _1) }
  end

  command :extracolorroles, {
    aliases: %i[ecr],
    help_available: true,
    usage: '.extracolorroles',
    min_args: 0,
    max_args: 0
  } do |event|
    records = ExtraColorRole.for(event.server)
    next embed QBot::Helpers.t('colors.extra-roles.list.empty') if records.empty?

    roles = records.pluck(:role_id).map { event.server.role(_1) }

    embed do |m|
      m.title = QBot::Helpers.t('colors.extra-roles.list.title')
      m.description = roles.map { |role|
        color_code = role.color.hex.rjust(6, '0')
        "`##{color_code}`: `#{role.id}` #{role.mention}"
      }.join("\n")
    end
  end

  command :addextracolorrole, {
    aliases: %i[aecr],
    help_available: true,
    usage: '.addextracolorrole <role>',
    min_args: 1,
    max_args: 1,
    arg_types: [Discordrb::Role]
  } do |event, role|
    next embed QBot::Helpers.t('colors.extra-roles.bad-role') unless role

    ExtraColorRole.for(event.server).create(role_id: role.id)
    embed QBot::Helpers.t('colors.extra-roles.add.success', role.mention)
  rescue ActiveRecord::RecordNotUnique
    embed QBot::Helpers.t('colors.extra-roles.add.duplicate', role.mention)
  end

  command :delextracolorrole, {
    aliases: %i[decr],
    help_available: true,
    usage: '.delextracolorrole <role>',
    min_args: 1,
    max_args: 1,
    arg_types: [Discordrb::Role]
  } do |event, role|
    next embed QBot::Helpers.t('colors.extra-roles.bad-role') unless role

    ExtraColorRole.for(event.server).find_by!(role_id: role.id).destroy
    embed QBot::Helpers.t('colors.extra-roles.del.success', role.mention)
  rescue ActiveRecord::RecordNotFound
    embed QBot::Helpers.t('colors.extra-roles.del.not-found', role.mention)
  end
end
