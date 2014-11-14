require 'rails_helper'

describe ApplicationController, type: :controller do
  # http://gayleforce.wordpress.com/2012/12/01/testing-rails-before_filter-method/
  # https://www.relishapp.com/rspec/rspec-rails/v/3-1/docs/controller-specs/anonymous-controller
  controller do
    def index
      simple_respond nil, status: :no_content
    end
  end

  it 'verify Timezone header' do
    login User.all.sample
    request.env['HTTP_TIMEZONE'] = nil
    get :index
    expect(response).to have_http_status :precondition_required
    expect(respond_json['message']).to eq 'Header Timezone is required'
  end
end
