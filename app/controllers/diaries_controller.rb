class DiariesController < ApplicationController
  helper_method :clean_content

  def show
    @diary = current_user.mail_receivers.find_by_local_note_date params[:id]
    if @diary.nil? or @diary.notes.count == 0
      error_info = build_error 'Diary not exist', errors: []
      return simple_respond error_info, status: :not_found
    end
    respond_to do |format|
      format.json
      format.xml
    end
  end

  protected

  def clean_content note
    return note.content.url if note.is_a? ImageNote
    NoteHelper.clean_content note.content
  end
end
