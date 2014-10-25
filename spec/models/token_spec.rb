require 'rails_helper'

describe Token do
  before(:all) { @user = create :user }

  before { @token = Token.new user: @user }

  subject { @token }

  it { is_expected.to have_readonly_attribute :id }
  its(:id) { is_expected.not_to be_nil }

  it { is_expected.to have_readonly_attribute :user }

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
end
