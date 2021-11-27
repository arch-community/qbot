# frozen_string_literal: true

p 'asdfkljhlkjhalkjsdflk'
module ConfigSample
  extend Discordrb::Commands::CommandContainer
end

ServerConfig.register_options do # rubocop: disable Metrics/BlockLength
  snowflake :log_channel, aliases: [:lc]
  string :prefix, aliases: %i[pfx], max_length: 10

  group :colors do
    collection :extra_roles do
      model ExtraColorRole

      id :server
      key :role_id

      format do |event, cr|
        role = event.server.role(cr.role_id)
        hex = role.color.hex.rjust(6, '0')
        "##{hex} #{role.id} #{role.name}"
      end
    end

    bool :bare_colors, aliases: [:bc], default: false
  end

  collection :snippet do
    model Snippet

    id :server
    key :name
    value :text

    prop :embed, :boolean, aliases: [:m], default: false
  end

  collection :blacklist do
    model BlacklistEntry
    id :server, :channel
    key :index

    format { |_, entry| "`#{entry.id}`: `#{entry.regex}`" }

    cmd :clear do |event|
      bl = BlacklistEntry.where(channel_id: event.channel.id)
      count = bl.count
      bl.delete_all
      count
    end
  end

  cmd :echo do |_, *args|
    args.join(' ')
  end

  string :test
  bool :test2, default: true
end

UserConfig.register_options do
  selection :language do
    options { I18n.available_locales }
    key(&:to_s)
    default { I18n.default_locale.to_s }

    on_save { |name| I18n.locale = name.to_sym }
  end

  group :sitelenpona, aliases: [:sp] do
    string :fgcolor, default: 'black'
    string :bgcolor, default: 'white'
    integer :fontsize, aliases: %i[size fs], default: 32

    selection :fontface, aliases: %i[ff] do
      options { SPGen.font_metadata }
      key :index
      default 'linja suwi'
    end

    string :name do
      default { |event| event.user.nickname }
    end

    string :glyphs, default: nil
  end
end
