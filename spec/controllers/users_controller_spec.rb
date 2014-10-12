require 'spec_helper'

describe UsersController, type: :controller do
  describe '#create' do
    it 'return the created user' do
      post :create, email: 'test@test.com'
      expect(response).to have_http_status :created
      expect(respond_json['email']).to eq 'test@test.com'
    end
  end
end
