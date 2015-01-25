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

  describe '#build_error' do
    it 'will format ActiveModel::Errors' do
      controller = ApplicationController.new
      message = 'Note error'
      errors = ActiveModel::Errors.new build :note
      errors[:content] = "invalid"
      expect(controller.instance_eval { build_error(message, errors)[:errors] })
        .to eq [resource: 'Note', field: 'content', code: 'invalid']
    end

    it 'only format ActiveModel::Errors' do
      controller = ApplicationController.new
      message = 'Note error'
      errors = [resource: 'Note', field: 'content', code: 'invalid']
      expect(controller.instance_eval { build_error(message, errors)[:errors] })
        .to eq [resource: 'Note', field: 'content', code: 'invalid']
    end
  end
end
