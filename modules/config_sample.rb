# frozen_string_literal: true

module ConfigSample; end

QBot.register_config do
  scope :server
  group :example do
    db :opt1, :string
    db :opt2, :integer
    db :optfour, :boolean, aliases: [:opt4]

    group :example2 do
      db :optthree, :selection do
        default { QBot.config.default_font }
        options { QBot.config.fonts }
        allow :one
      end
    end

    group :snippet do
      cmd :list do
        Snippet.all
      end
      cmd :add do |_, *text|
        Snippet.create text.join(' ')
      end
      group :prop do |arg|
        base { Snippet.where(name: arg).first }
        prop :embed, :boolean, aliases: [:m], default: false
      end
    end
  end
end
