# frozen_string_literal: true

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

I18n.load_path << Dir["#{File.expand_path('lib/locales')}/*.yml"]
I18n.config.available_locales = %i[en tp en_kawaii]
I18n.default_locale = :en
I18n.fallbacks = [ :en ]

def t(tid, *fields)
  I18n.t(tid) % fields
end

def embed(text = nil, target: nil)
  target ||= QBot.bot.embed_target
  reply_target = target.is_a?(Discordrb::Events::MessageEvent) ? target.message : nil

  target.send_embed('', nil, nil, false, false, reply_target) do |m|
    m.description = text if text
    yield m if block_given?
  end
end
