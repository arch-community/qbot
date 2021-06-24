# frozen_string_literal: true

require 'set'

# Manages bot modules
module QBotModules
  def all_modules
    @all_modules ||= Set.new
  end

  def load_module(name)
    @all_modules ||= Set.new

    QBot.log.info "Loading module: #{name}"
    load File.join(__dir__, '..', 'modules', "#{name}.rb")

    include! name.camelize.constantize

    @all_modules << name.to_sym
  end

  def load_all_modules
    @config.modules.each do
       load_module _1
    end
  end
end
