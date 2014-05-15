class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token

  def respond(result, opts)
    request_format = Mime::Type.lookup(request.accepts.first)
    request_format = :json unless [:xml, :json].include? request_format

    opts = opts.deep_dup
    opts[request_format] = result

    render opts
  end
end
