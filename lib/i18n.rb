# frozen_string_literal: true

I18n.load_path << Dir["#{File.expand_path('lib/locales')}/*.yml"]
I18n.config.available_locales = %i[en tp en_kawaii]
I18n.default_locale = :en

def t(tid, *fields)
  I18n.t(tid) % fields
end

def embed(text = nil, target: nil)
  channel = target || QBot.bot.embed_target

  channel.send_embed do |m|
    m.description = text if text
    yield m if block_given?
  end
end
