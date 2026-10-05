# frozen_string_literal: true

require_relative 'configurable/option_types'
require_relative 'configurable/option'
require_relative 'configurable/column_option'
require_relative 'configurable/schema_builder'

##
# Included into classes that can have configuration options registered.
module Configurable
  extend ActiveSupport::Concern

  class_methods do
    def schema
      @schema ||= {}
    end

    def option(*path)
      schema.dig(*path)
    end

    def extend_schema(&)
      builder = SchemaBuilder.new
      builder.build(&)

      schema.deep_merge!(builder.options)
    end
  end

  private def resolve_option(path)
    option = self.class.option(*path)
    raise ArgumentError, "unknown option #{path.inspect}" if option.nil?

    option
  end

  def get_option(path, ...)
    resolve_option(path).get_for_record(self, ...)
  end

  def set_option(path, ...)
    resolve_option(path).set_for_record(self, ...)
  end

  def [](*path, **rest)
    get_option(path, **rest)
  end

  def []=(*path, (new_value, *args))
    set_option(path, new_value, *args)
  end
end
