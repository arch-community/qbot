# frozen_string_literal: true

##
# Base class for all Tantiny indexes
class ApplicationIndex < SimpleDelegator
  include Singleton

  def self.path = raise NotImplementedError

  def self.instantiate(&)
    Tantiny::Index.new(path, &)
  end

  def self.clear
    FileUtils.rm_rf(path)
    instance.reset
  end

  def reset
    @index = self.class.instantiate
    __setobj__(@index)
    @index.reload
  end

  attr_accessor :index

  def initialize
    @index = self.class.instantiate
    @index.reload

    super(@index)
  end
end
