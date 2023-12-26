# frozen_string_literal: true

require_relative 'colors/wrapped_color_role'

ServerConfig.extend_schema do
  option :use_bare_colors, TBoolean.new, default: false

  option :auto_assign_colors,
         TEnum.new(%w[on_join on_screening_pass never]),
         default: 'on_join'
end

# rubocop: disable Metrics/ModuleLength

##
# Color role assignment
module Colors
  extend Discordrb::Commands::CommandContainer

  ##
  # Check if a string represents a hex color code, '#XXXXXX' or 'XXXXXX'
  def self.hex_code?(string) = string.match?(/^#?[[:xdigit:]]{6}$/)

  ##
  # Assigns a role to a member, ensuring they have only one from a given list.
  def self.assign_color_role(member, new_role)
    all_roles = ColorRole.for(member.server).map(&:role)

    if member.role?(new_role)
      embed t('colors.assign-role.already-have')
    else
      member.modify_roles(new_role, all_roles, 'Change color')
      embed t('colors.assign-role.success', role.name)
    end
  end

  command :color, {
    aliases: [:c],
    help_available: true,
    usage: '.c <color>',
    min_args: 1
  } do |event, *args|
    new_role = ColorRole.search(event.server, args.join(' '))
    next embed t('colors.color.not-found') unless new_role

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
    next embed t('colors.closest.invalid-hex', target) unless is_valid 

    closest = ColorRole.find_closest_on(server, target)
    embed t('colors.closest.found', closest.hex_code)

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
      m.title = t('colors.list.title')
      m.description = lines.join("\n")
    end
  end

  ##
  # Randomize colors embed
  class RCEmbed
    attr_accessor :msg, :count

    private def mk_embed(description = '')
      { title: t('colors.rc.begin', @count), description: }
    end

    def initialize(count)
      @count = count
      @msg = yield mk_embed
    end

    def progress=(index)
      embed = mk_embed(t('colors.rc.progress', index, @count))
      @msg.edit('', embed)
    end

    def finish!
      embed = { title: t('colors.rc.success', @count) }
      @msg.edit('', embed)
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
    next embed t('no_perms') unless event.author.permission?(:manage_roles)

    randomize_color_roles(event.server) { event.send_embed('', _1) }
  end

  ##
  # Embed for creating color roles
  class CCREmbed
    attr_accessor :msg, :embeds

    def update_msg!
      @msg.edit('', embeds.values)
    end

    def initialize(old_count)
      @embeds = {}
      @old_count = old_count
      @new_count = nil

      deleting_embed = {
        title: t('colors.ccr.deleting', old_count),
        description: ''
      }

      @embeds[:deleting] = deleting_embed

      @msg = yield @embeds.values
    end

    def show_role_delete!(role, index)
      message = \
        t('colors.ccr.deleted', index, @old_count, role.name)

      @embeds[:deleting][:description] += "#{message}\n"

      update_msg!
    end

    def begin_create_stage!(count)
      @new_count = count

      creating_embed = {
        title: t('colors.ccr.creating', count),
        description: ''
      }

      @embeds[:creating] = creating_embed

      update_msg!
    end

    def show_role_create!(role, index)
      message = \
        t('colors.ccr.created', index, @new_count, role.mention, role.hex_code)

      @embeds[:creating][:description] += "#{message}\n"

      update_msg!
    end

    def success!
      success_embed = { title: t('colors.ccr.success', @new_count) }
      @embeds[:success] = success_embed

      update_msg!
    end
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
    next embed t('no_perms') unless event.author.permission?(:manage_roles)

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
    next embed t('colors.extra-roles.list.empty') if records.empty?

    roles = records.pluck(:role_id).map { event.server.role(_1) }

    embed do |m|
      m.title = t('colors.extra-roles.list.title')
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
    next embed t('colors.extra-roles.bad-role') unless role

    ExtraColorRole.for(event.server).create(role_id: role.id)
    embed t('colors.extra-roles.add.success', role.mention)
  rescue ActiveRecord::RecordNotUnique
    embed t('colors.extra-roles.add.duplicate', role.mention)
  end

  command :delextracolorrole, {
    aliases: %i[decr],
    help_available: true,
    usage: '.delextracolorrole <role>',
    min_args: 1,
    max_args: 1,
    arg_types: [Discordrb::Role]
  } do |event, role|
    next embed t('colors.extra-roles.bad-role') unless role

    ExtraColorRole.for(event.server).find_by!(role_id: role.id).destroy
    embed t('colors.extra-roles.del.success', role.mention)
  rescue ActiveRecord::RecordNotFound
    embed t('colors.extra-roles.del.not-found', role.mention)
  end
end
# rubocop: enable Metrics/ModuleLength

## Event container for the Colors module
module ColorsEvents
  extend Discordrb::EventContainer

  # Color roles on join

  member_leave do |event|
    PendingMember.for(event.server).destroy_by(user_id: event.user.id)
  end

  def give_random_color(server, user)
    new_role = Colors::ColorRole.for(server).sample.role
    user.add_role(new_role)
  end

  member_join do |event|
    opt = ServerConfig.for(event.server)[:auto_assign_colors]

    give_random_color(event.server, event.user) if opt == 'on_join'
  end

  raw(type: :GUILD_MEMBER_ADD) do |event|
    server_id = event.data['guild_id'].to_i
    opt = ServerConfig.for(server_id)[:auto_assign_colors]

    if opt == 'on_screening_pass' && event.data['pending']
      user_id = event.data.dig('user', 'id')
      PendingMember.create!(server_id:, user_id:)
    end
  end

  raw(type: :GUILD_MEMBER_UPDATE) do |event|
    server_id = event.data['guild_id'].to_i
    opt = ServerConfig.for(server_id)[:auto_assign_colors]

    if opt == 'on_screening_pass' && event.data['pending'] == false
      user_id = event.data.dig('user', 'id')
      record = PendingMember.find_by!(server_id:, user_id:)

      server = event.bot.server(server_id)
      member = server.member(user_id)

      give_random_color(server, member)
      record.destroy!
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end

module Colors
  include! ColorsEvents
end
