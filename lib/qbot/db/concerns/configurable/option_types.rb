# frozen_string_literal: true

require 'abbrev'

module Configurable
  module OptionTypes
    ##
    # Generic option type interface
    module OptionType
      ##
      # Read a value of this type form a string
      def read(_input) = raise NotImplementedError
      def format_value(_value) = raise TypeError

      def short_name = raise NotImplementedError
      def describe_self = raise NotImplementedError
      def describe_validation = raise NotImplementedError
    end

    ##
    # String values, with length constraints
    class TString
      include OptionType

      attr_reader :min_size, :max_size

      def initialize(min_size: 0, max_size: nil)
        raise ArgumentError if min_size.negative?
        raise ArgumentError if max_size&.< min_size

        @min_size, @max_size = min_size, max_size
      end

      def read(input)
        raise TypeError if (input.size < @min_size) || (@max_size&.< input.size)

        input
      end

      def format_value(value)
        if value.include? "\n"
          "```\n#{value}\n```"
        else
          "`#{value}`"
        end
      end

      def short_name = t('types.string.name')
      def describe_self = t('types.string.desc')

      def describe_validation
        if @max_size
          t('types.string.valid.between', @min_size, @max_size)
        else
          t('types.string.valid.at-least', @min_size)
        end
      end
    end

    ##
    # Integer values, with min/max constraints
    class TInteger
      include OptionType

      attr_reader :min, :max

      def initialize(min: nil, max: nil)
        raise ArgumentError if min && max && (min > max)

        @min, @max = min, max
      end

      def read(input)
        res = Integer(input)

        raise ArgumentError if @min && res < @min
        raise ArgumentError if @max && res > @max

        res
      end

      def format_value(value) = "`#{value}`"

      def short_name = t('types.integer.name')
      def describe_self = t('types.integer.desc')

      def describe_validation
        if @min && @max
          t('types.integer.valid.between', @min, @max)
        elsif @min
          t('types.integer.valid.at-least', @min)
        elsif @max
          t('types.integer.valid.at-most', @max)
        else
          t('types.integer.valid.any')
        end
      end
    end

    ##
    # Discord Snowflakes
    class TSnowflake < TInteger
      FORMATS = {
        user: '<@%d>',
        channel: '<#%d>',
        role: '<@&%d>',
        emoji: '<:_:%d>',
        animated_emoji: '<a:_:%d>'
      }.freeze

      attr_reader :format

      def initialize(format: nil)
        raise ArgumentError if format && !(FORMATS.key? format)

        @format = format

        super(min: 0, max: (2**64) - 1)
      end

      def format_value(value)
        return t('types.empty') unless value

        if @format
          Kernel.format(FORMATS[@format], value)
        else
          super(value)
        end
      end

      def short_name = t('types.snowflake.name')
      def describe_self = t('types.snowflake.desc')

      def describe_validation
        if @format
          t("types.snowflake.valid.#{@format}")
        else
          t('types.snowflake.valid.bare')
        end
      end
    end

    ##
    # Booleans
    class TBoolean
      def read(value)
        ActiveModel::Type::Boolean.new.cast(value.chomp.downcase)
      end

      def format_value(value) = value.to_s.downcase

      def short_name = t('types.boolean.name')
      def describe_self = t('types.boolean.desc')
      def describe_validation = t('types.boolean.valid')
    end

    ##
    # Enums, lets you select one value from a list
    class TEnum
      attr_reader :options

      def initialize(options)
        raise ArgumentError if options.empty?

        @options = options.map { String(_1) }
      end

      def find_by_index(index)
        is_valid = index.between?(0, @options.count - 1)

        raise ArgumentError, t('types.enum.invalid-index') unless is_valid

        @options[index]
      end

      def find_by_abbrev(query)
        @abbrev ||= @options.abbrev

        raise ArgumentError, t('types.enum.invalid-key') \
          unless @abbrev.key?(query)

        @abbrev[query]
      end

      def read(raw_input)
        input = raw_input.strip

        index = parse_int(input)
        return find_by_index(index) if index

        find_by_abbrev(input)
      end

      def format_value(value, columns = 0, index = nil)
        index ||= @options.index(value.to_s)

        if index
          index_f = index.to_s.rjust(columns, ' ')
          "`#{index_f}`: #{value}"
        else
          value.to_s
        end
      end

      def short_name = t('types.enum.name')

      def describe_self = t('types.enum.desc')

      def describe_validation(options = @options)
        n_digits = (options.count - 1).to_s.length

        rows = options.map.with_index { |v, i| format_value(v, n_digits, i) }

        rows.join("\n")
      end
    end
  end
end
