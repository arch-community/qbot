# frozen_string_literal: true

# Note
class Note < ActiveRecord::Base
  include ServerScoped

  validates :name, length: { maximum: 32 }
  validates :text, length: { minimum: 1, maximum: 2000 }

  PAGE_SIZE = 20

  def self.page_count(size: PAGE_SIZE)
    (count / size.to_f).ceil
  end

  def self.page_index_valid?(index, ...)
    index.between?(0, page_count(...) - 1)
  end

  def self.find_random!(query)
    where(name: query.downcase)
      .order('RANDOM()')
      .take!
  end

  scope :page, ->(index, size: PAGE_SIZE) { limit(size).offset(index * size) }

  scope :page!, (lambda do |index, size: PAGE_SIZE|
    raise ActiveRecord::RangeError unless page_index_valid?(index, size:)

    page(index, size:)
  end)

  def str_server_id
    server_id.to_s
  end

  after_save do
    NoteIndex.instance << self
  end

  after_destroy do
    NoteIndex.instance.delete(self)
  end

  def self.populate_index
    ni = NoteIndex.instance

    ni.transaction do
      all.each { ni << _1 }
    end

    ni.reload
  end

  def self.text_search(str)
    server_id = all.scope_for_create['server_id']
    find(NoteIndex.instance.note_id_query(str, server_id:))
  end
end
