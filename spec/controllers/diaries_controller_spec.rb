require 'rails_helper'

describe DiariesController, type: :controller do
  before(:all) do
    @user = create :user
    create :mail_receiver, user: @user, local_note_date: '2013-01-01'
    5.times do |time|
      mail_receiver = create :mail_receiver, user: @user, local_note_date: "2013-02-0#{1 + time}"
      10.times do |i|
        klass = i % 2 ? TextNote : ImageNode
        build(:note, mail_receiver: mail_receiver).becomes!(klass).save!
      end
    end
  end

  describe '#show' do
    it 'need authentication' do
      get :show, id: Time.now.to_date
      expect(response).to have_http_status :unauthorized
    end

    it "return current user's diary in specified date" do
      mail_receivers = @user.mail_receivers
      query_note_date = "2013-02-0#{Array(1..5).sample}"
      expected_ids = mail_receivers.find_by_local_note_date(query_note_date).notes.map(&:id)
      login @user
      get :show, id: query_note_date
      expect(response).to have_http_status :ok
      expect(respond_json['notes'].map(&['id'])).to eq expected_ids
      respond_json['notes'].each_with_index do |note, index|
        expect(note['type']).to eq index % 2 ? 'text' : 'image'
      end
    end

    it 'return 404 if there was no diary in specified date' do
      login @user
      get :show, id: '9999-12-31'
      expect(response).to have_http_status :not_found
      get :show, id: '2013-01-01'
      expect(response).to have_http_status :not_found
    end
  end
end
