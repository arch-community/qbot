# frozen_string_literal: true

##
# Modules can register configuration with the bot. It is exposed to users.
module ConfigRegistry
  def self.included(base)
    base.extend(ClassMethods)
  end

  ##
  # Represents an option in the option tree. If it's a group, it contains sub-options.
  Option = Struct.new(*%i[name type aliases default attrs])

  # valid types: %i[string integer snowflake bool group selection collection command]

  ##
  # Context used to store build state for a selection option.
  SelectionContext = Struct.new(*%i[name limit key options default on_save])

  ##
  # Context used to store build state for a collection option.
  CollectionContext = Struct.new(*%i[model ids key value format props]) do
    # make props initialize to an array by default
    def initialize(*)
      super
      self.props ||= []
    end
  end

  ##
  # Stores a property of a collection option.
  CollectionProperty = Struct.new(*%i[name type aliases default])

  ##
  # Holds configuration options.
  class ConfigBuilder
    EMPTY = Object.new

    attr_accessor :options

    def initialize
      @scope = :server
      @context = []
      @group_stack = []
      @options = []
    end

    # rubocop: disable Style/TrivialAccessors
    def scope(arg)
      @scope = arg
    end
    # rubocop: enable Style/TrivialAccessors

    ##
    # Adds an option to the current option scope.
    def add_opt(option)
      if (head = @group_stack.last)
        head.attrs << option
      else
        @options << option
      end
    end

    def group(name, aliases: [], &block)
      group = Option.new(name, :group, aliases, nil, [])
      @group_stack.push(group)
      instance_eval(&block) if block_given?

      add_opt @group_stack.pop
    end

    def selection(name, aliases: [], &block)
      @context = SelectionContext.new
      instance_eval(&block) if block_given?

      add_opt Option.new(name, :selection, aliases, nil, @context)
      @context = nil
    end

    %i[string integer snowflake bool].each do |type|
      define_method type do |name, aliases: [], default: nil, **kwargs|
        @options << Option.new(name, type, aliases, default, kwargs)
      end
    end

    def collection(name, aliases: [], &block)
      @context = CollectionContext.new
      instance_eval(&block) if block_given?

      add_opt Option.new(name, :collection, aliases, nil, @context)
      @context = nil
    end

    def model(name)
      @context.model = name
    end

    def id(*ids)
      @context.ids = ids
    end

    def key(sym = nil, &block)
      @context.key = block_given? ? block : sym
    end

    def default(val = nil, &block)
      @context.default = block_given? ? block : val
    end

    def on_save(&block)
      @context.on_save = block
    end

    def value(sym)
      @context.value = sym
    end

    def prop(name, type, aliases: [], default: nil)
      @context.props << CollectionProperty.new(name, type, aliases, default)
    end

    def format(&block)
      @context.format = block if block_given?
    end

    def cmd(name, aliases: [], &block)
      add_opt Option.new(name, :command, aliases, nil, &block)
    end
  end

  ##
  # Contains the method to register configuration.
  module ClassMethods
    def register_config(&block)
      opts = ConfigBuilder.new
      opts.instance_eval(&block)
      pp opts.options
    end
  end
end
