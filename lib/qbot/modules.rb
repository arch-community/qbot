# frozen_string_literal: true

require 'set'

# Manages bot modules
module Modules
  @all = Set.new

  class << self; attr_accessor :all; end

  def self.load_module(name)
    QBot.log.info "Loading module: #{name}"
    load "./modules/#{name}.rb"

    # not sure how else this is possible?
    # rubocop: disable Security/Eval
    eval "QBot.bot.include! #{name.capitalize}", binding, __FILE__, __LINE__
    # rubocop: enable Security/Eval

    @all << name.to_sym
  end

  def self.load_all
    QBot.config.global.modules.each do
       load_module _1
    end
  end
end
