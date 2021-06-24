# frozen_string_literal: true

##
# Modules can register configuration with the bot. It is exposed to users.
module ConfigRegistry
  def self.included(base)
    base.extend(ClassMethods)
  end

  ##
  # A configuration handler attribute.
  # Can either be a block (executed at command call) or a value (stored).
  class HandlerAttr
    def initialize(value = nil, &block)
      if block_given?
        @blk = block
      end
      @val = value
    end

    def [](event, *args, **kwargs)
      return val if val
      return blk[event, *args, **kwargs] if blk
    end
  end

  ##
  # Holds configuration options.
  class OptionSet
    EMPTY = Object.new

    attr_accessor :handlers

    def initialize
      @context = nil
      @group_stack = []
      @handlers = {}

      @db_opt = nil
      @db_type = nil
    end

    def method_missing(name, value = EMPTY, &block)
      if value == EMPTY && !block
        instance_variable_get("@#{name}")
      elsif block
        instance_variable_set("@#{name}", block)
      elsif value != empty
        instance_variable_set("@#{name}", value)
      end
    end

    def respond_to_missing?(_, *)
      true
    end

    def group(name, &block)
      @group_stack.push(name)
      instance_eval(&block)
      @group_stack.pop
    end

    def cmd(name, &block)
      @handlers[[*@group_stack, name]] = HandlerAttr.new(&block)
    end

    def db(name, type, aliases: [], &block)
      @db_opt = @group_stack.join('.') + name.to_s
      @db_type = type
      instance_eval(&block)

      case type
        when :selection
        else
      end
    end

    def default(val = nil, &block)
    end

    def options
    end

    def allow
    end

    def base(obj = nil, &block)
      @context = HandlerAttr.new(obj || nil, &block)
    end

    def prop(name, type, aliases: [], default: [])
      if @context
        cmd :set do |event, value|
          @context.send("#{name}=", value)
        end
      end
    end
  end

  ##
  # Contains the method to register configuration.
  module ClassMethods
    def register_config(&block)
      opts = OptionSet.new
      opts.instance_eval(&block)
      pp opts.handlers
    end
  end
end
