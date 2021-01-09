# frozen_string_literal: true

I18n.load_path << Dir[File.expand_path("lib/locales") + "/*.yml"]
I18n.config.available_locales = [ :en, :tp ]
I18n.default_locale = :en

def t tid, *fields
  I18n.t(tid) % fields
end

def embed(event, text)
  event.channel.send_embed { _1.description = text }
end
