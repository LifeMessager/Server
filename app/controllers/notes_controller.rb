class NotesController < ApplicationController
  def create
    unless note.save
      error_info = build_error 'Create note failed', note.errors
      return simple_respond error_info, status: :unprocessable_entity
    end
    respond_to do |format|
      format.json { render json: note, status: :created }
      format.xml  { render  xml: note, status: :created }
    end
  end

  private

  def info_for_create
    {content: params[:content]}
  end

  def note
    return @note if @note
    local_note_date = MailReceiver.current_date_in_timezone current_user.timezone
    mail_receiver = MailReceiver.find_or_create_by user: current_user, local_note_date: local_note_date
    klass = params[:type] == 'image' ? ImageNote : TextNote
    @note = klass.new info_for_create.merge mail_receiver: mail_receiver, from_email: current_user.email
  end
end
