# frozen_string_literal: true

module Colors
  ##
  # Presenter methods for Colors module embeds and formatting
  module Presenters
    ##
    # Format extra color roles for embed display
    def self.extra_color_roles_description(roles)
      roles.map { |role|
        color_code = role.color.hex.rjust(6, '0')
        "`##{color_code}`: `#{role.id}` #{role.mention}"
      }.join("\n")
    end
  end
end
