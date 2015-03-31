require 'rails_helper'

RSpec.describe NotesController, :type => :controller do
  let(:user) { create :user }

  describe "POST create" do
    it 'need authentication' do
      post :create, content: 'hello world'
      expect(response).to have_http_status :unauthorized
    end

    it "create today's note to current user" do
      content = "hello world\n\n\naaa"
      login user
      post :create, content: content
      expect(response).to have_http_status :created
      user.reload
      expect(user.notes.length).to eq 1
      mail_receiver = user.notes.first.mail_receiver
      expect(user.notes.first.content).to eq content
      expect(user.notes.first.type).to eq 'TextNote'
      expect(mail_receiver.locale_date).to eq MailReceiver.current_date_in_timezone mail_receiver.timezone
    end

    it "can create image note" do
      login user
      post :create, content: fixture_file_upload('lifemessager.png', 'image/png'), type: 'image'
      expect(response).to have_http_status :created
      user.reload
      expect(user.notes.length).to eq 1
      expect(user.notes.first.type).to eq 'ImageNote'
    end
  end
end
