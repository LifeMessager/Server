class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token

  private

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
