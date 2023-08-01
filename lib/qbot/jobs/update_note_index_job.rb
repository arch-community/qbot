# frozen_string_literal: true

##
# Job to update the note index
class UpdateNoteIndexJob < ApplicationJob
  def perform
    NoteIndex.clear
    Note.populate_index
  end
end
