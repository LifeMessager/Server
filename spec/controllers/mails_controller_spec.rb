require 'rails_helper'

describe MailsController, type: :controller do
  describe "#notes" do
    before do
      @mail_receiver = create :mail_receiver
      @mail_data = {
        'sender' => @mail_receiver.user.email,
        'recipient' => @mail_receiver.full_address,
        'stripped-text' => 'hello world',
        'Date' => DateTime.now.to_json
      }
    end

    it 'create a new note and return http status `created`' do
      post :notes, @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
      expect(@mail_receiver.notes.first.content).to eq @mail_data['stripped-text']
    end

    it 'allow any sender' do
      @mail_data['sender'] = 'not-exist-address'
      post :notes, @mail_data
      expect(response).to have_http_status :created
      expect(@mail_receiver.notes.length).to eq 1
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
