require 'rails_helper'

describe UsersController, type: :controller do
  describe '#create' do
    it 'return the created user' do
      expect(UserMailer).to receive(:welcome).and_call_original do |user|
        expect(user.email).to eq 'test@test.com'
      end
      post :create, email: 'test@test.com'
      expect(response).to have_http_status :created
      expect(respond_json['email']).to eq 'test@test.com'
    end
  end

  describe '#subscribe' do
    it 'need authentication' do
      user = create :user, subscribed: false
      put :subscribe, user_id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it 'subscribe mail for user' do
      user = create :user, subscribed: false
      login user
      put :subscribe, user_id: user.id
      expect(response).to have_http_status :created
      user.reload
      expect(user.subscribed).to be true
    end
  end

  describe '#unsubscribe' do
    before { @user = create :user, subscribed: true }

    context 'when request with Authorization header' do
      it 'unsubscribe mail for user' do
        request.env['HTTP_AUTHORIZATION'] = "unsubscribe #{@user.unsubscribe_token}"
        delete :unsubscribe, user_id: @user.id
        expect(response).to have_http_status :no_content
        @user.reload
        expect(@user.subscribed).to be false
      end
    end

    context 'when request without Authorization header' do
      it 'return an error' do
        delete :unsubscribe, user_id: @user.id
        expect(response).to have_http_status :unauthorized
        expect(@user.subscribed).to be true
      end
    end

    it 'support unsubscribe from mail link' do
      get :unsubscribe, user_id: @user.id, _method: 'delete', token: "unsubscribe #{@user.unsubscribe_token}"
      expect(response).to have_http_status :no_content
    end
  end

  describe '#send_login_mail' do
    before(:all) { @user = create :user }

    it 'send a mail contain valid token' do
      expect(UserMailer).to receive(:login).and_call_original do |user|
        expect(user.email).to eq @user.email
      end
      post :send_login_mail, email: @user.email
      expect(response).to have_http_status :created
    end
  end
end
