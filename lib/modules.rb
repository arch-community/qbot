require 'set'

module Modules
   @all = Set.new

   class << self; attr_accessor :all; end

   def Modules.load_module(name)
      $applog.info "Loading module: #{name}"
      load "./modules/#{name}.rb"
      eval "$bot.include! #{name.capitalize}"
      @all << name.to_sym
   end

   def Modules.load_all
      $config.global.modules.each do
         load_module _1
      end
   end
end
