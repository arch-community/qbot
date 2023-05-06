# frozen_string_literal: true

module Configurable
  ##
  # Represents a configuration option stored in a column.
  # The root is ignored, the column name is only based on `name`.
  class ColumnOption < Option
    def default_for_record(record)
      return @default if @default

      defaults = record.class.column_defaults
      defaults[@name]
    end

    def get_for_record(record, ...)
      res = record.send(@name)

      if res
        run_hooks(:on_load, res, ...)
        res
      else
        default_for_record(record)
      end
    end

    def set_for_record(record, new_value, ...)
      run_hooks(:before_save, new_value, ...)

      record.send("#{@name}=", new_value)
      record.save!

      run_hooks(:on_save, new_value, ...)
      new_value
    end
  end
end
