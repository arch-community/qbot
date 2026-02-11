# frozen_string_literal: true

# Manages bot modules
module Modules
  @loaded_modules = Set.new

  class << self; attr_accessor :all; end

  def self.load_module(name)
    QBot.log.info "Loading module: #{name}"
    load File.join(__dir__, *%W[.. .. modules #{name}.rb])

    QBot.bot.include!(name.camelize.constantize)

    @loaded_modules << name.to_sym
  end

  def self.load_all
    QBot.config.modules.each do |name|
      load_module(name)
    end
  end
end
