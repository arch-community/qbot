# frozen_string_literal: true

module Colors
  ##
  # Randomize colors embed
  class RCEmbed
    attr_accessor :msg, :count

    private def mk_embed(description = '')
      { title: QBot::Helpers.t('colors.rc.begin', @count), description: }
    end

    def initialize(count)
      @count = count
      @msg = yield mk_embed
    end

    def progress=(index)
      embed = mk_embed(QBot::Helpers.t('colors.rc.progress', index, @count))
      @msg.edit('', embed)
    end

    def finish!
      embed = { title: QBot::Helpers.t('colors.rc.success', @count) }
      @msg.edit('', embed)
    end
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
        title: QBot::Helpers.t('colors.ccr.deleting', old_count),
        description: ''
      }

      @embeds[:deleting] = deleting_embed

      @msg = yield @embeds.values
    end

    def show_role_delete!(role, index)
      message = \
        QBot::Helpers.t('colors.ccr.deleted', index, @old_count, role.name)

      @embeds[:deleting][:description] += "#{message}\n"

      update_msg!
    end

    def begin_create_stage!(count)
      @new_count = count

      creating_embed = {
        title: QBot::Helpers.t('colors.ccr.creating', count),
        description: ''
      }

      @embeds[:creating] = creating_embed

      update_msg!
    end

    def show_role_create!(role, index)
      message = \
        QBot::Helpers.t('colors.ccr.created', index, @new_count, role.mention, role.hex_code)

      @embeds[:creating][:description] += "#{message}\n"

      update_msg!
    end

    def success!
      success_embed = { title: QBot::Helpers.t('colors.ccr.success', @new_count) }
      @embeds[:success] = success_embed

      update_msg!
    end
  end
end
