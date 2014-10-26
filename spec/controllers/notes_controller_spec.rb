require 'rails_helper'

describe NotesController, type: :controller do
  before(:all) do
    @user = create :user
    mail_receiver = create :mail_receiver
    10.times { |i| create :note, mail_receiver: mail_receiver }
  end

  describe '#index' do
    it 'need authentication' do
      get :index, user_id: @user
      expect(response).to have_http_status :unauthorized
    end

    it "return current user's all notes" do
      login @user
      get :index, user_id: @user
      expect(response).to have_http_status :ok
      expect(respond_json.map(&[:id])).to eq @user.notes.map(&:id)
    end
  end
end
