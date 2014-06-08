require 'spec_helper'

describe MailController do

  describe "POST 'receivers'" do
    it "returns http success" do
      post 'receivers'
      response.should be_success
    end
  end
end
