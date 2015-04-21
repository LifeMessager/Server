require 'rails_helper'
require 'securerandom'

expected_user_info_keys = ['id', 'email', 'created_at', 'deleted_at', 'subscribed', 'timezone', 'alert_time']

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

    context 'when user count limited' do
      after { Settings['user_limit'] = nil }

      it 'do nothing if user creatable' do
        Settings['user_limit'] = User.count + 1
        userinfo = attributes_for :user
        post :create, userinfo
        expect(response).to have_http_status :created
      end

      it 'return error if user count overflow' do
        Settings['user_limit'] = User.count
        userinfo = attributes_for :user
        post :create, userinfo
        expect(response).to have_http_status :forbidden
        expect(respond_json).to include({'message' => 'Registered user overflow'})
      end
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

    it 'can get deleted user' do
      user.destroy!
      login user
      get :show, id: user.id
      expect(response).to have_http_status :ok
      expect(respond_json['deleted_at']).to eq Time.zone.now.as_json
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
      expect(user.timezone.identifier).to eq changed_timezone
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

    it 'will not update user email' do
      login user
      patch :update, id: user.id, email: 'aaa@bbb.com'
      expect(response).to have_http_status :ok
      expect(respond_json).to include *expected_user_info_keys
      expect(respond_json['email']).not_to eq 'aaa@bbb.com'
      user.reload
      expect(user.email).not_to eq 'aaa@bbb.com'
    end
  end

  describe '#destroy' do
    let(:user) { create :user }

    it 'need authentication' do
      delete :destroy, id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it 'will mark user deleted' do
      expect(UserMailer).to receive(:destroyed).and_call_original do |receive_user|
        expect(receive_user.email).to eq user.email
      end
      login user
      delete :destroy, id: user.id
      expect(response).to have_http_status :no_content
      user.reload
      expect(user).to be_deleted
    end
  end

  describe '#cancel_destroy' do
    let(:user) { create :user, deleted_at: Time.now }

    it 'need authentication' do
      post :cancel_destroy, id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it 'restore deleted user' do
      login user
      post :cancel_destroy, id: user.id
      expect(response).to have_http_status :no_content
      user.reload
      expect(user).not_to be_destroyed
    end
  end

  describe '#get_current_user' do
    it 'need authentication' do
      get :get_current_user
      expect(response).to have_http_status :unauthorized
    end

    it 'return current user info' do
      user = create :user
      login user
      get :get_current_user
      expect(response).to have_http_status :ok
      expect(respond_json.slice *expected_user_info_keys).to eq JSON.parse(user.to_json).slice *expected_user_info_keys
    end
  end

  describe '#subscribe' do
    let(:user) do
      result = create :user
      result.send :subscribed=, false
      result
    end

    it 'need authentication' do
      put :subscribe, id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it 'subscribe mail for user' do
      login user
      put :subscribe, id: user.id
      expect(response).to have_http_status :created
      user.reload
      expect(user.subscribed).to be true
    end
  end

  describe '#unsubscribe' do
    before do
      @user = create :user
      @user.send :subscribed=, true
    end

    context 'when request with Authorization header' do
      it 'unsubscribe mail for user' do
        request.env['HTTP_AUTHORIZATION'] = "unsubscribe #{@user.unsubscribe_token}"
        delete :unsubscribe, id: @user.id
        expect(response).to have_http_status :no_content
        @user.reload
        expect(@user.subscribed).to be false
      end
    end

    context 'when request without Authorization header' do
      it 'return an error' do
        delete :unsubscribe, id: @user.id
        expect(response).to have_http_status :unauthorized
        expect(@user.subscribed).to be true
      end
    end

    it 'support unsubscribe from mail link' do
      get :unsubscribe, id: @user.id, _method: 'delete', token: "unsubscribe #{@user.unsubscribe_token}"
      expect(response).to have_http_status :no_content
    end
  end

  describe '#apply_change_email' do
    let(:user) { create :user }

    it 'require authentication' do
      post :apply_change_email, id: user.id, email: 'test@example.com'
      expect(response).to have_http_status :unauthorized
    end

    it 'return the created user' do
      expect(UserMailer).to receive(:change_email).and_call_original do |target_user, email|
        expect(email).to eq 'test@example.com'
        expect(target_user).to eq user
      end

      login user
      post :apply_change_email, id: user.id, email: 'test@example.com'
      expect(response).to have_http_status :created
    end

    it 'validate email format' do
      login user
      post :apply_change_email, id: user.id, email: 'test'
      expect(response).to have_http_status :unprocessable_entity
      expect(respond_json).to match(
                                "message" => 'Validation Failed',
                                "errors" => [{
                                  "resource" => 'User',
                                  "field" => 'email',
                                  "code" => 'invalid'
                                }]
                              )
    end

    it 'will not send mail if address not change' do
      expect(UserMailer).not_to receive(:change_email)
      login user
      post :apply_change_email, id: user.id, email: user.email
      expect(response).to have_http_status :created
    end
  end

  describe '#change_email' do
    let(:user) { create :user }

    it 'require authentication' do
      put :change_email, id: user.id
      expect(response).to have_http_status :unauthorized
    end

    it "change user's email address" do
      target_email = "test#{SecureRandom.hex}@example.com"
      token = user.change_email_token target_email
      request.env['HTTP_AUTHORIZATION'] = "change_email #{token}"
      put :change_email, id: user.id
      expect(response).to have_http_status :ok
      user.reload
      expect(user.email).to eq target_email
    end

    it 'check user validity' do
      another_user = create :user
      target_email = "test#{SecureRandom.hex}@example.com"
      token = another_user.change_email_token target_email
      request.env['HTTP_AUTHORIZATION'] = "change_email #{token}"
      put :change_email, id: user.id
      expect(response).to have_http_status :unauthorized
    end
  end
end
