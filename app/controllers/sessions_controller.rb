class SessionsController < ApplicationController
  skip_before_action :verify_token, only: [:send_login_mail]

  def send_login_mail
    user = User.find_by_email params[:email].downcase
    if user.nil?
      data = build_error 'Login failed', [{resource: 'User', field: 'email', code: 'missing'}]
      return simple_respond data, status: :unprocessable_entity
    end
    UserMailer.login(user).deliver_now
    simple_respond nil, status: :created
  end

  def create
    @token = Token.new user: current_user, expired_interval: Token::EXPIRED_INTERVAL
    respond_to do |format|
      format.json { render status: :created }
      format.xml  { render status: :created }
    end
  end
end
