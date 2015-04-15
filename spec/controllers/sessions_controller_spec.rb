require 'rails_helper'

describe SessionsController, type: :controller do
  before(:all) { @user = create :user }

  describe '#send_login_mail' do
    it 'send a mail contain valid token' do
      expect(UserMailer).to receive(:login).and_call_original do |user|
        expect(user.email).to eq @user.email
      end
      post :send_login_mail, email: @user.email
      expect(response).to have_http_status :created
    end

    context 'if user not exist' do
      it 'return an error' do
        post :send_login_mail, email: 'not-exist@example.com'
        expect(response).to have_http_status :unprocessable_entity
        expect(respond_json['errors'].first.symbolize_keys).to eq resource: 'User', field: 'email', code: 'missing'
      end
    end
  end

  describe '#create' do
    it 'require Authentication header' do
      post :create
      expect(response).to have_http_status :unauthorized
    end

    it 'require a valid Authentication header' do
      request.env['HTTP_AUTHORIZATION'] = "Bearer invalid token"
      post :create
      expect(response).to have_http_status :unauthorized
    end

    it 'return a persistent token' do
      login @user
      post :create
      expect(response).to have_http_status :created
      expect(respond_json['expired_at']).to eq (Time.now + Token::EXPIRED_INTERVAL).as_json
      result = Token.decode respond_json['token']
      expect(result).to include success: true
      expect(result[:token].user).to eq @user
    end
  end
end
