# frozen_string_literal: true

module Configurable
  ##
  # Provides a DSL for defining configuration options.
  class SchemaBuilder
    attr_reader :options

    def initialize
      @path = []
      @options = {}
    end

    def current_group
      return @options if @path.empty?

      @options.dig(*@path)
    end

    def build(&)
      Object.class_eval do
        define_singleton_method :const_missing do |name|
          self.class.const_get "::Configurable::OptionTypes::#{name}"
        end
      end

      instance_eval(&)

      Object.singleton_class.class_eval do
        remove_method :const_missing
      end
    end

    def group(name, &)
      current_group[name] ||= {}

      @path.push name
      instance_eval(&)
      @path.pop
    end

    private def generic_option(option_class, name, ...)
      current_group[name] = option_class.new(@path, name, ...)
    end

    def option(...) = generic_option(Option, ...)
    def column_option(...) = generic_option(ColumnOption, ...)
  end
end
