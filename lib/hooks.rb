# frozen_string_literal: true

def can_run?(name, event)
  m = ServerConfig[event.server.id].modules

  m.filter_map { _1.to_s.camelize.constantize&.commands&.keys }
   .any? { _1.include? name }
end

# Check server modules
QBot.hook do |event, name|
  can_run?(name, event)
end

# Set the user's locale for response strings
QBot.hook do |event|
  uc = UserConfig[event.user.id]
  lang = uc.contents && uc.contents['lang']&.to_sym || I18n.default_locale
  I18n.locale = lang
end

# Log the event
QBot.hook do |event|
  log(event)
end

# Set various context variables for commands to use
QBot.hook do |event|
  @embed_target = event
  @current_prefix = find_prefix(event.message)
end
