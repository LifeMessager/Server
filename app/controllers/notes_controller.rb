class NotesController < ApplicationController
  def index
    notes = User.find_by_id(params[:user_id]).notes
    respond orginaze_notes(notes), status: :ok
  end

  private

  def orginaze_notes(notes)
    notes.group_by(&:note_date).map do |note_date, grouped_notes|
      {note_date: note_date, notes: grouped_notes}
    end
  end
end
