# frozen_string_literal: true

module Configurable
  ##
  # Represents a configuration option.
  # The option's description and other user-visible text is located
  # in the translation files, and looked up by the option's path.
  # for example, for path [:foo, :bar]: t('options.foo.bar.description')
  class Option
    attr_reader :root, :name, :type, :path, :default

    def initialize(root, name, type, default: nil, &block)
      @root = root
      @name = name
      @path = [*root, name]
      @type = type

      @default = default

      @hooks = Hash.new { |h, k| h[k] = [] }

      instance_eval(&block) if block_given?
    end

    def add_hook(type, &hook)
      @hooks[type] << hook
    end

    def on_load(...) = add_hook(:on_load, ...)
    def before_save(...) = add_hook(:before_save, ...)
    def on_save(...) = add_hook(:on_save, ...)

    def run_hooks(type, value, ...)
      @hooks[type].each { _1.call(self, value, ...) }
    end

    def dot_path = @path.map(&:to_s).join('.')
    def ui_path = @path.map(&:inspect).join

    def localized_name = t("cfg.option.#{dot_path}.name")
    def description = t("cfg.option.#{dot_path}.description")

    def default_for_record(_)
      @default
    end

    def ensure_root(record)
      cwd = record.contents ||= {}
      @path => [*root, _]

      root.each do |name|
        key = name.to_s

        cwd[key] ||= {}
        cwd = cwd[key]
      end

      cwd
    end

    def get_for_record(record, ...)
      cwd = ensure_root(record)
      val = cwd[@name.to_s]

      if val
        yield val if block_given?
        val
      else
        @default
      end
    end

    def set_for_record(record, new_value, ...)
      cwd = ensure_root(record)

      cwd[@name.to_s] = new_value
      record.save!

      new_value
    end

    def show(val)
      return t('cfg.option.unset') if val.nil?

      @type.format_value(val)
    end

    def show_value(...) = show(get_for_record(...))
    def show_default(...) = show(default_for_record(...))
  end
end
