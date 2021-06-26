# frozen_string_literal: true

module ConfigSample
  extend Discordrb::Commands::CommandContainer
end

QBot.register_config do # rubocop: disable Metrics/BlockLength
  scope :server

  snowflake :log_channel, aliases: [:lc]
  string :prefix, aliases: %i[p pfx], max_length: 10

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

    cmd :clear do
      bl = BlacklistEntry.where(channel_id: channel_id)
      count = bl.count
      bl.delete_all
      count
    end
  end
end

QBot.register_config do
  scope :user

  selection :language do
    options { I18n.available_locales }
    key(&:to_s)
    default { I18n.default_locale.to_s }

    on_save { |name| I18n.locale = name.to_sym }
  end

  group :sitelenpona, aliases: [:sp] do
    string :fgcolor, aliases: [:fg], default: 'black'
    string :bgcolor, aliases: [:bg], default: 'white'
    integer :fontsize, aliases: %i[size fs s], default: 32

    selection :fontface, aliases: %i[fontface font ff f] do
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
