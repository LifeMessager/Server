class ErrorsController < ApplicationController
  skip_before_action :verify_token
  skip_before_action :verify_timezone_header

  def not_found
    data = build_error 'Resource Not Found'
    simple_respond data, status: :not_found
  end

  def internal_server_error
    data = build_error 'Internal Server Error'
    simple_respond data, status: :internal_server_error
  end

  def service_unavailable
    data = build_error 'Service Unavailable'
    simple_respond data, status: :service_unavailable
  end
end
