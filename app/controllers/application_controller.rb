class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  before_action :verify_token

  private

  def verify_token
    unless current_user
      error = build_resp 'Header Authorization is required'
      return respond(error, status: :unauthorized)
    end
  end

  def current_user
    return false unless authorization
    return false unless authorization[:type] == 'Bearer'
    token = Token.decode authorization[:token]
    return false unless token[:success]
    token[:token].user
  end

  def authorization
    auth = request.authorization || params[:token]
    return unless auth
    auth_parts = auth.split ' ', 2
    { type: auth_parts.first, token: auth_parts.last }
  end

  def respond(resp, opts)
    request_format = Mime::Type.lookup(request.accepts.first)
    request_format = :json unless [:xml, :json].include? request_format

    opts = opts.deep_dup
    opts[request_format] = fill_default_resp resp, opts

    render opts
  end

  def build_resp message, *args
    { message: message, errors: args.first || [] }
  end

  def fill_default_resp resp, opts
    case opts[:status]
    when :not_found
      { message: 'Resource not found', errors: [] }.merge resp
    else
      resp
    end
  end
end
