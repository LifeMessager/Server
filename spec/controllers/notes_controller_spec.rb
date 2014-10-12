require 'spec_helper'

describe NotesController, type: :controller do
  describe '#index' do
    it "return current user's all notes" do
      get :index, user_id: User.first.id
      expect(response).to have_http_status :ok
      expect(respond_json.map(&[:id])).to eq User.first.notes.map(&:id)
    end
  end
end
