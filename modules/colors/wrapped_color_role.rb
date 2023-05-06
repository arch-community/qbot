# frozen_string_literal: true

require 'forwardable'

module Colors
  ##
  # ActiveModel object holding a color role.
  class ColorRole
    include ActiveModel::Model
    extend Forwardable

    GENERATED_SUFFIX = ' [c]'

    attr_accessor :role, :type

    def_delegators :@role, :name, :mention

    def self.ordered_roles_for(server) =
      server.roles.sort_by(&:position).reverse

    def self.mk_get(type, roles, &) =
      roles.filter(&).map { new(role: _1, type:) }

    def self.get_generated(roles) =
      mk_get(:generated, roles) { _1.name.end_with? GENERATED_SUFFIX }

    def self.get_bare(roles) =
      mk_get(:bare, roles) { Colors.hex_code? _1.name }

    def self.get_extra(roles, server_id)
      extra_ids = ExtraColorRole.for(server_id).pluck(:role_id)

      mk_get(:extra, roles) { extra_ids.include? _1.id }
    end

    def self.use_bare?(server) =
      ServerConfig.for(server.id)[:use_bare_colors]

    ##
    # Finds all roles on a server that are considered "color roles".
    # Has options to turn off each heuristic it uses.
    def self.for(server, generated: true, bare: use_bare?(server), extra: true)
      all_roles = ordered_roles_for(server)

      res = []
      res += get_generated(all_roles) if generated
      res += get_bare(all_roles) if bare
      res += get_extra(all_roles, server.id) if extra

      res
    end

    ##
    # Finds a role from a given list that matches a given unique prefix.
    def self.find_role_by_name(roles, query)
      lower_map = roles.to_h { [_1.name.downcase, _1] }

      abbrevs = lower_map.keys.abbrev

      abbrevs[query.strip.downcase]&.then { lower_map[_1] }
    end

    ##
    # Uses heuristics to find a role by user input.
    def self.search(server, query)
      roles = self.for(server)

      # If input looks like an integer n, return the nth role
      index = parse_int(query)
      return roles[index] if index

      # otherwise:
      find_role_by_name(roles, query)
    end

    ##
    # Returns the color role with the closest color to the one given,
    # using the CIE76 distance metric in CIELAB color space
    def self.find_closest_on(server, target_hex)
      target = ColorLib.hex_to_lab(target_hex.remove_prefix('#'))

      self.for(server).min_by { |cur|
        compare = ColorLib.hex_to_lab(cur.hex_bare)
        ColorLib.cie76(target, compare)
      }
    end

    ##
    # Create a role with a name that will be detected as a color role
    def self.create_generated(server, hex, index)
      role = server.create_role(
        name: "color#{index}#{GENERATED_SUFFIX}",
        colour: Discordrb::ColourRGB.new(hex),
        permissions: 0,
        reason: 'Generating color roles'
      )

      new(role:, type: :generated)
    end

    ##
    # Generate a list of varied colors at around the same perceptual brightness
    # by sampling `num` points on a ring of radius `num` on a lightness plane
    # in CIELAB color space.
    def self.color_ring(lightness, radius, count)
      angle = 2 * Math::PI / count

      (0...count).map do |index|
        this_angle = angle * index
        a = radius * Math.cos(this_angle)
        b = radius * Math.sin(this_angle)

        ColorLib.lab_to_hex [lightness, a, b]
      end
    end

    def hex_bare = @role.color.hex.rjust(6, '0')
    def hex_code = "##{hex_bare}"

    def to_list_line(index = 0, total_count = 0)
      col_width = (total_count - 1).to_s.size
      index_col = index.to_s.rjust(col_width)

      "`#{index_col}:` `#{hex_code}` #{mention}"
    end

    def move_to_bottom!
      @role.move_above(@role.server.everyone_role)
    end

    def destroy!(reason = '')
      @role.delete(reason)
    end
  end
end
