require 'spec_helper'

describe UsersController do
  describe '#create' do
    it 'should work' do
      post :create, email: 'test@test.com'
      response.should be_success
      respond_json['email'].should eq 'test@test.com'
    end
  end
end
