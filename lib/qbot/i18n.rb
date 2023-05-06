# frozen_string_literal: true

I18n::Backend::Simple.include I18n::Backend::Fallbacks

locales_dir = File.join(__dir__, *%w[.. .. share locales])
I18n.load_path << Dir["#{locales_dir}/*.yml"]

I18n.config.available_locales = %i[en tok en_kawaii de]
I18n.default_locale = :en
I18n.fallbacks = [:en]

##
# Option type for choosing a locale
class TLocaleEnum < Configurable::OptionTypes::TEnum
  def initialize
    super(I18n.available_locales)
  end

  def format_value(value, ...)
    str = "`#{value}` (#{t("locales.#{value}")})"

    super(str, ...)
  end
end

UserConfig.extend_schema do
  option :language, TLocaleEnum.new, default: I18n.default_locale
end

def t(tid, *fields)
  I18n.translate!(tid) % fields
rescue I18n::MissingTranslationData
  "#{I18n.translate(tid)} #{fields.inspect}"
end
