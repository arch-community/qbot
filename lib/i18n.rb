# frozen_string_literal: true

I18n.load_path << Dir[File.expand_path("lib/locales") + "/*.yml"]
I18n.config.available_locales = [ :en, :tp ]
I18n.default_locale = :tp

def t event, tid, *fields
  uc = UserConfig[event.user.id]
  lang = uc.contents && uc.contents['lang']&.to_sym || :en
  
  I18n.t(tid, locale: lang) % fields
end

def embed(event, text)
  event.channel.send_embed { _1.description = text }
end

