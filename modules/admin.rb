# frozen_string_literal: true

load './modules/admin/config.rb'
load './modules/admin/user_config.rb'

# Administration commands
module Admin
  extend Discordrb::Commands::CommandContainer

  command :eval, {
    help_available: false,
    usage: '.eval <code>',
    min_args: 1
  } do |e, *args|
    log(e)

    _ = m = e.message # rubocop: disable Lint/UselessAssignment
    a = e.author
    if a.id == QBot.config.owner
      eval args.join(' ') # rubocop: disable Security/Eval
    else
      t('admin.eval.nope')
    end
  end

  command :modules, {
    help_available: true,
    usage: '.modules',
    min_args: 0, max_args: 0
  } do |e|
    embed do |m|
      m.title = t('admin.modules.title')
      m.fields = [
        {
          name: t('admin.modules.global'),
          value: QBot.config.global.modules.join(', ')
        }
      ]
      if QBot.config.servers[e.server.id]&.modules
        m.fields << {
          name: t('admin.modules.local'),
          value: Config[e.server.id].modules
        }
      end
    end
  end
end
