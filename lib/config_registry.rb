# frozen_string_literal: true

##
# Modules can register configuration with the bot. It is exposed to users.
module ConfigRegistry
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        attr_accessor :server_options, :user_options
      end

      @server_options ||= []
      @user_options ||= []
    end
  end

  ##
  # Represents an option in the option tree. If it's a group, it contains sub-options.
  Option = Struct.new(*%i[name type aliases default attrs scope]) do
    def get_config(event)
      if scope == :user
        UserConfig[event.user.id]
      else
        ServerConfig[event.server.id]
      end
    end

    def get(event)
      case type
      when :string, :integer, :bool, :snowflake
        get_config(event).options[name.to_s]
      when :selection
      when :collection
      end
    end

    def db_set(event, value)
      cfg = get_config(event)
      p cfg.options
      cfg.options[name] = value
      cfg.save!
    end
  end

  # valid types: %i[string integer snowflake bool group selection collection command]

  ##
  # Context used to store build state for a selection option.
  SelectionContext = Struct.new(*%i[name limit key options default on_save extra_cmds])

  ##
  # Context used to store build state for a collection option.
  CollectionContext = Struct.new(*%i[model ids key value format props extra_cmds]) do
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
  # Holds extra commands for a selection or collection.
  CommandContainer = Struct.new(:attrs) do
    # make attrs initialize to an array by default
    def initialize(*)
      super
      self.attrs ||= []
    end
  end

  ##
  # Represents either a value or a block.
  # When called, returns either the block's result or the value.
  # Block takes priority.
  class ValueBlock
    attr_accessor :blk, :val

    def initialize(val = nil, &block)
      @blk = block if block_given?
      @val = val
    end

    def [](*args, **kwargs)
      return @blk[*args, **kwargs] if @blk

      @val
    end
  end

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

    def scope(arg = nil)
      return @scope unless arg

      @scope = arg
    end

    ##
    # Adds an option to the current option scope.
    def add_opt(option)
      option.scope = @scope
      if (head = @group_stack.last)
        head.attrs << option
      else
        @options << option
      end
    end

    ##
    # Group option. Contains other options.
    def group(name, aliases: [], &block)
      group = Option.new(name, :group, aliases, nil, [])
      @group_stack.push(group)
      instance_eval(&block) if block_given?

      add_opt @group_stack.pop
    end

    ##
    # Selection option. Lets the user select from a list.
    def selection(name, aliases: [], &block)
      @context = SelectionContext.new
      @group_stack << CommandContainer.new
      instance_eval(&block) if block_given?

      @context.extra_cmds = @group_stack.pop
      add_opt Option.new(name, :selection, aliases, nil, @context)
      @context = nil
    end

    ##
    # Database key options. Stored as keys under the `options` hash.
    %i[string integer snowflake bool].each do |type|
      define_method type do |name, aliases: [], default: nil, **kwargs|
        add_opt Option.new(name, type, aliases, default, kwargs)
      end
    end

    ##
    # Collection option. Allows managing collections.
    def collection(name, aliases: [], &block)
      @context = CollectionContext.new
      @group_stack << CommandContainer.new
      instance_eval(&block) if block_given?

      @context.extra_cmds = @group_stack.pop
      add_opt Option.new(name, :collection, aliases, nil, @context)
      @context = nil
    end

    # Collection support options

    def model(name)
      @context.model = name
    end

    def id(*ids)
      @context.ids = ids
    end

    def key(val = nil, &block)
      @context.key = ValueBlock.new(val, &block)
    end

    def default(val = nil, &block)
      @context.default = ValueBlock.new(val, &block)
    end

    def on_save(&block)
      @context.on_save = block
    end

    def value(sym)
      @context.value = sym
    end

    def format(&block)
      @context.format = block if block_given?
    end

    ##
    # Property option. Lets the user set a property of an object in a collection.
    def prop(name, type, aliases: [], default: nil)
      @context.props << CollectionProperty.new(name, type, aliases, default)
    end

    ##
    # Command option. Allows defining custom commands.
    def cmd(name, aliases: [], &block)
      add_opt Option.new(name, :command, aliases, nil, block)
    end
  end

  ##
  # Contains the method to register configuration.
  module ClassMethods
    def register_config(&block)
      opts = ConfigBuilder.new
      opts.instance_eval(&block)
      pp opts.options

      case opts.scope
      when :server
        @server_options += opts.options
      when :user
        @user_options += opts.options
      end
    end
  end
end
