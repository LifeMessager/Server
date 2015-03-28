require 'rails_helper'

describe MailsController, type: :controller do
  describe "#notes" do
    before do
      @mail_receiver = create :mail_receiver
      @mail_data = {
        'sender' => @mail_receiver.user.email,
        'recipient' => @mail_receiver.full_address,
        'stripped-text' => "hello world\n\n\naaa",
        'Date' => DateTime.now.to_json,
      }
    end

    it 'create a new note and return http status `created`' do
      post :notes, @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
      expect(@mail_receiver.notes.first).to be_a TextNote
      expect(@mail_receiver.notes.first.content).to eq @mail_data['stripped-text']
    end

    it 'create a new note with deliverer recipient with registered user' do
      @mail_data['recipient'] = Settings.mailer_deliverer_full_address
      post :notes, @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
      expect(@mail_receiver.notes.first).to be_a TextNote
    end

    it 'allow any sender' do
      @mail_data['sender'] = 'not-exist-address@example.com'
      post :notes, @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
    end

    it 'do nothing with error format sender' do
      @mail_data['sender'] = 'invalid sender'
      post :notes, @mail_data
      expect(response).to have_http_status :ok
      expect(@mail_receiver.notes.length).to eq 0
    end

    it 'do nothing with error format recipient' do
      @mail_data['recipient'] = 'invalid recipient'
      post :notes, @mail_data
      expect(response).to have_http_status :ok
      expect(@mail_receiver.notes.length).to eq 0
    end

    it 'do nothing with invalid recipient' do
      @mail_data['recipient'] = 'post+hello@lifemessager.com'
      post :notes, @mail_data
      expect(response).to have_http_status :ok
      expect(@mail_receiver.notes.length).to eq 0
    end

    it 'do nothing with deliverer recipient with unregistered user' do
      @mail_data['recipient'] = Settings.mailer_deliver_from
      @mail_data['sender'] = 'not-registered-user@example.com'
      post :notes, @mail_data
      expect(response).to have_http_status :ok
      expect(@mail_receiver.notes.length).to eq 0
    end

    it 'do nothing with empty content' do
      @mail_data['stripped-text'] = nil
      post :notes, @mail_data
      expect(response).to have_http_status :ok
      expect(@mail_receiver.notes.length).to eq 0
    end

    context 'when mail have attachments' do
      before { @mail_data['stripped-text'] = nil }
      after do
        ImageNote.send :remove_const, :LARGEST_SIZE
        ImageNote::LARGEST_SIZE = 2.megabytes
      end

      it 'ignore image which extension not allowed' do
        @mail_data['attachment-count'] = '1'
        @mail_data['attachment-1'] = fixture_file_upload 'lifemessager.txt', 'text/plain'
        post :notes, @mail_data
        expect(response).to have_http_status :ok
        expect(@mail_receiver.notes.length).to eq 0
      end

      it 'ignore image which size larger than specified size' do
        ImageNote.send :remove_const, :LARGEST_SIZE
        ImageNote::LARGEST_SIZE = 14.kilobytes
        @mail_data['attachment-count'] = '1'
        @mail_data['attachment-1'] = fixture_file_upload 'lifemessager.png', 'image/png'
        post :notes, @mail_data
        expect(response).to have_http_status :ok
        expect(@mail_receiver.notes.length).to eq 0
      end

      it 'save image as a note of diary' do
        @mail_data['puts'] = true
        @mail_data['attachment-count'] = '1'
        @mail_data['attachment-1'] = fixture_file_upload 'lifemessager.png', 'image/png'
        post :notes, @mail_data
        expect(response).to have_http_status :created
        expect(@mail_receiver.notes.length).to eq 1
        expect(@mail_receiver.notes.first).to be_a ImageNote
      end

      it 'can handler multiple image' do
        @mail_data['puts'] = true
        @mail_data['attachment-count'] = '3'
        3.times do |index|
          @mail_data["attachment-#{index + 1}"] = fixture_file_upload 'lifemessager.png', 'image/png'
        end
        post :notes, @mail_data
        expect(response).to have_http_status :created
        expect(@mail_receiver.notes.length).to eq 3
        @mail_receiver.notes.find_each { |note| expect(note).to be_a ImageNote }
      end

      it 'can handler a email have both text and image' do
        @mail_data['attachment-count'] = '1'
        @mail_data['attachment-1'] = fixture_file_upload 'lifemessager.png', 'image/png'
        @mail_data['stripped-text'] = 'hello world'
        post :notes, @mail_data
        expect(response).to have_http_status :created
        expect(@mail_receiver.notes.length).to eq 2
        expect(@mail_receiver.notes).to include TextNote
        expect(@mail_receiver.notes).to include ImageNote
      end
    end
  end

  describe '#unsubscriptions' do
    before do
      @user = create :user
      @mail_data = {
        'sender' => @user.email,
        'recipient' => @user.unsubscribe_email_address,
        'stripped-text' => '',
        'Date' => DateTime.now.to_json
      }
    end

    it 'unsubscribe diary mail for user' do
      post :unsubscriptions, @mail_data
      @user.reload
      expect(@user.subscribed).to be false
    end

    it 'do nothing with invalid sender' do
      @mail_data['sender'] = 'invalid-sender'
      post :unsubscriptions, @mail_data
      @user.reload
      expect(@user.subscribed).to be true
    end

    it 'do nothing with invalid unsubscribe token' do
      @mail_data['recipient'] = 'unsubscribe+aaaa@lifemessager.com'
      post :unsubscriptions, @mail_data
      @user.reload
      expect(@user.subscribed).to be true
    end
  end
end
