class DiariesController < ApplicationController
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
end
