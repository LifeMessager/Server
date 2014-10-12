require 'spec_helper'

describe MailsController, type: :controller do
  describe "POST /receivers" do
    before do
      @mail_receiver = create :mail_receiver
      @mail_data = {
        'sender' => @mail_receiver.user.email,
        'recipient' => "#{@mail_receiver.address}@example.com",
        'stripped-text' => 'hello world',
        'Date' => DateTime.now.to_json
      }
    end

    it 'create a new note and returns http status `created`' do
      post 'receivers', @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
    end
  end
end
