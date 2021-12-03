# frozen_string_literal: true

require_relative 'admin/config'

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
    scfg = e.channel.pm? ? nil : ServerConfig[e.server.id]

    embed do |m|
      m.title = t('admin.modules.title')
      m.fields = [{
        name: t('admin.modules.global'),
        value: e.bot.config.modules.join(', ')
      }]

      if scfg
        m.fields << {
          name: t('admin.modules.local'),
          value: if scfg.all_modules?
                   t('admin.modules.all_on')
                 elsif scfg.modules.empty?
                   t('admin.modules.none')
                 else
                   scfg.modules.join(', ')
                 end
        }
      end
    end
  end
end
