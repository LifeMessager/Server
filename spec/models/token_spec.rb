# coding: utf-8
require 'rails_helper'

describe Token do
  before(:all) { @user = create :user }

  before { @token = Token.new user: @user }

  subject { @token }

  it { is_expected.to have_pattr_writer :id }
  its(:id) { is_expected.not_to be_nil }

  it { is_expected.to have_pattr_writer :user }

  describe '.new' do
    it 'receive :expired_interval option' do
      token = Token.new user: @user, expired_interval: -10
      decode_info = Token.decode token.id
      expect(decode_info[:success]).to be false
      expect(decode_info[:message]).to eq 'token expired'
    end

    it 'receive :secret option' do
      token = Token.new user: @user, secret: 'secret'

      correct_decode_info = Token.decode token.id, secret: 'secret'
      expect(correct_decode_info[:success]).to be true
      expect(correct_decode_info[:token].user.id).to eq @user.id

      wrong_decode_info = Token.decode token.id
      expect(wrong_decode_info[:success]).to be false
      expect(wrong_decode_info[:message]).to eq 'unprocessable token'
    end

    it 'receive :data option to take extra data' do
      token = Token.new user: @user, data: {key: 'value'}
      decode_info = Token.decode token.id
      expect(decode_info).to include success: true
      expect(decode_info[:token].data).to include 'key' => 'value'
    end

    it 'receive :id option to deserialize jwt' do
      new_token = Token.new id: @token.id
      expect(new_token).to have_attributes(id: @token.id)
                      .and have_attributes(user: @user)
                      .and have_attributes(data: @token.data)
      # 因为 @token.expired_at 可能是 2015-04-21 06:04:01.143773819 +0000
      # 而 new_token.expired_at 只能是 2015-04-21 06:04:01.000000000 +0000
      expect(new_token.expired_at.to_i).to eq @token.expired_at.to_i
    end
  end

  describe '.decode' do
    subject { Token }

    it { is_expected.to respond_to :decode }

    context 'in success case' do
      it 'return decoded token data' do
        decode_info = Token.decode @token.id
        expect(decode_info[:success]).to be true
        expect(decode_info[:token].user.id).to eq @user.id
      end
    end

    context 'if token is invalid' do
      it 'return error' do
        decode_info = Token.decode 'invalid token'
        expect(decode_info[:success]).to be false
        expect(decode_info[:message]).to eq 'unprocessable token'
      end
    end

    context 'if user in token not exist' do
      it 'return error' do
        user = User.new id: 9999
        token = Token.new user: user
        decode_info = Token.decode token.id
        expect(decode_info[:success]).to be false
        expect(decode_info[:message]).to eq 'user not exist'
      end
    end
  end

  describe '.to_url' do
    it 'generate login url' do
      expected_url = "http://#{Settings.server_name}/#!/login?token=#{@token.id}"
      expect(@token.to_url).to eq expected_url
    end
  end
end
