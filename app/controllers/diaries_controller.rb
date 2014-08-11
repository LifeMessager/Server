class DiariesController < ApplicationController
  def index
    diaries = User.find_by_id(params[:user_id]).diaries
    respond orginaze_diaries(diaries), status: :ok
  end

  private

  def orginaze_diaries(diaries)
    diaries.group_by(&:create_date).map do |create_date, grouped_diaries|
      {create_date: create_date, diaries: grouped_diaries}
    end
  end
end
