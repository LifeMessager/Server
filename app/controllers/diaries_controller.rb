class DiariesController < ApplicationController
  def index
    diaries = User.find_by_id(params[:user_id]).diaries
    respond orginaze_diaries(diaries), status: :ok
  end

  private

  def orginaze_diaries(diaries)
    diaries.group_by(&:note_date).map do |note_date, grouped_diaries|
      {note_date: note_date, diaries: grouped_diaries}
    end
  end
end
