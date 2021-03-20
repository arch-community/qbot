# frozen_string_literal: true

I18n.load_path << Dir["#{File.expand_path('lib/locales')}/*.yml"]
I18n.config.available_locales = %i[en tp]
I18n.default_locale = :en

def t(tid, *fields)
  I18n.t(tid) % fields
end

def embed(text, target_channel = nil)
  channel = target_channel || QBot.bot.embed_target

  channel.send_embed do |m|
    m.description = text
    yield m if block_given?
  end
end
