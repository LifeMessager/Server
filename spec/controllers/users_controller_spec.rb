require 'rails_helper'

expected_user_info_keys = ['id', 'email', 'created_at', 'subscribed', 'timezone', 'alert_time']

describe UsersController, type: :controller do
  describe '#create' do
    it 'return the created user' do
      expect(UserMailer).to receive(:welcome).and_call_original do |user|
        expect(user.email).to eq 'test@test.com'
      end
      userinfo = attributes_for :user
      post :create, userinfo
      expect(response).to have_http_status :created
      expect(respond_json).to include *expected_user_info_keys
    end
  end

  describe '#show' do
    let(:user) { create :user }

    it 'need authentication' do
      get :show, id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it 'return user info' do
      login user
      get :show, id: user.id
      expect(response).to have_http_status :ok
      expect(respond_json).to include *expected_user_info_keys
    end
  end

  describe '#update' do
    let(:user) { create :user }

    it 'need authentication' do
      patch :update, id: user.id, timezone: User.timezones.sample
      expect(response).to have_http_status :unauthorized
    end

    it 'allow update user timezone' do
      login user
      changed_timezone = User.timezones.sample
      patch :update, id: user.id, timezone: changed_timezone
      expect(response).to have_http_status :ok
      expect(respond_json).to include *expected_user_info_keys
      expect(respond_json['timezone']).to eq changed_timezone
      user.reload
      expect(user.timezone).to eq changed_timezone
    end

    it 'allow update user alert_time' do
      login user
      patch :update, id: user.id, alert_time: '01:00'
      expect(response).to have_http_status :ok
      expect(respond_json).to include *expected_user_info_keys
      expect(respond_json['alert_time']).to eq '01:00'
      user.reload
      expect(user.alert_time).to eq '01:00'
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

    context 'if user not exist' do
      it 'return an error' do
        post :send_login_mail, email: 'not-exist@example.com'
        expect(response).to have_http_status :unprocessable_entity
        expect(respond_json['errors'].first.symbolize_keys).to eq resource: 'User', field: 'email', code: 'missing'
      end
    end
  end
end
