# frozen_string_literal: true

require_relative 'colors/wrapped_color_role'
require_relative 'colors/embeds'
require_relative 'colors/commands'
require_relative 'colors/events'

ServerConfig.extend_schema do
  option :use_bare_colors, TBoolean.new, default: false

  option :auto_assign_colors,
         TEnum.new(%w[on_join on_screening_pass never]),
         default: 'on_join'
end

##
# Color role assignment
module Colors
  extend Discordrb::Commands::CommandContainer

  include! ColorsEvents
end
