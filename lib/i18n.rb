# frozen_string_literal: true

I18n::Backend::Simple.include I18n::Backend::Fallbacks

I18n.load_path << Dir["#{File.join(__dir__, 'locales')}/*.yml"]
I18n.config.available_locales = %i[en tok en_kawaii de]
I18n.default_locale = :en
I18n.fallbacks = [:en]

def t(tid, *fields)
  I18n.translate!(tid) % fields
rescue I18n::MissingTranslationData
  "#{I18n.translate(tid)} #{fields.inspect}"
end

def locale_list
  I18n
    .available_locales
    .map { |lang| "`#{lang}`: #{t("locales.#{lang}")}" }
    .join("\n")
end

def embed(text = nil, target: nil)
  target ||= QBot.instance.embed_target
  pp target
  reply_target = target.is_a?(Discordrb::Events::MessageEvent) ? target.message : nil

  target.send_embed('', nil, nil, false, false, reply_target) do |m|
    m.description = text if text
    yield m if block_given?
  end
end
