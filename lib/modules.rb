require 'set'

module Modules
  @all = Set.new

  class << self; attr_accessor :all; end

  def self.load_module(name)
    QBot.log.info "Loading module: #{name}"
    load "./modules/#{name}.rb"
    eval "QBot.bot.include! #{name.capitalize}"
    @all << name.to_sym
  end

  def self.load_all
    QBot.config.global.modules.each do
       load_module _1
    end
  end
end
